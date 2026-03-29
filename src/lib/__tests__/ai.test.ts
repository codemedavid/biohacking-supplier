import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { generateProtocolWithAI } from '../ai';

// Mock fetch globally
const mockFetch = vi.fn();
vi.stubGlobal('fetch', mockFetch);

describe('generateProtocolWithAI', () => {
  let originalKey: string | undefined;

  beforeEach(() => {
    vi.clearAllMocks();
    // Save original and set test API key directly on import.meta.env
    originalKey = import.meta.env.VITE_OPENAI_API_KEY;
    import.meta.env.VITE_OPENAI_API_KEY = 'test-api-key';
  });

  afterEach(() => {
    // Restore original
    if (originalKey !== undefined) {
      import.meta.env.VITE_OPENAI_API_KEY = originalKey;
    } else {
      delete import.meta.env.VITE_OPENAI_API_KEY;
    }
  });

  it('returns parsed protocol on successful API response', async () => {
    const mockResponse = {
      dosage: '500mcg daily',
      frequency: 'Once daily',
      duration: '8-12 weeks',
      notes: ['Start low', 'Monitor effects'],
      storage: 'Refrigerate after reconstitution',
    };

    mockFetch.mockResolvedValueOnce({
      ok: true,
      json: async () => ({
        choices: [{ message: { content: JSON.stringify(mockResponse) } }],
      }),
    });

    const result = await generateProtocolWithAI('BPC-157', 'Healing peptide');

    expect(result.dosage).toBe('500mcg daily');
    expect(result.frequency).toBe('Once daily');
    expect(result.duration).toBe('8-12 weeks');
    expect(result.notes).toEqual(['Start low', 'Monitor effects']);
    expect(result.storage).toBe('Refrigerate after reconstitution');

    expect(mockFetch).toHaveBeenCalledWith(
      'https://api.openai.com/v1/chat/completions',
      expect.objectContaining({
        method: 'POST',
        headers: expect.objectContaining({
          'Authorization': 'Bearer test-api-key',
        }),
      })
    );
  });

  it('uses fallback values for missing fields in AI response', async () => {
    mockFetch.mockResolvedValueOnce({
      ok: true,
      json: async () => ({
        choices: [{ message: { content: JSON.stringify({}) } }],
      }),
    });

    const result = await generateProtocolWithAI('TB-500', 'Test');

    expect(result.dosage).toBe('Consult physician');
    expect(result.frequency).toBe('Consult physician');
    expect(result.duration).toBe('Consult physician');
    expect(result.notes).toEqual(['Consult physician']);
    expect(result.storage).toBe('Store in cool, dry place');
  });

  it('throws error when API returns non-ok response', async () => {
    mockFetch.mockResolvedValueOnce({
      ok: false,
      json: async () => ({ error: { message: 'Rate limit exceeded' } }),
    });

    await expect(generateProtocolWithAI('BPC-157', 'Test')).rejects.toThrow('Rate limit exceeded');
  });

  it('throws error when no content in response', async () => {
    mockFetch.mockResolvedValueOnce({
      ok: true,
      json: async () => ({
        choices: [{ message: { content: null } }],
      }),
    });

    await expect(generateProtocolWithAI('BPC-157', 'Test')).rejects.toThrow('No content received from AI');
  });

  it('throws error when AI returns invalid JSON', async () => {
    mockFetch.mockResolvedValueOnce({
      ok: true,
      json: async () => ({
        choices: [{ message: { content: 'not valid json' } }],
      }),
    });

    await expect(generateProtocolWithAI('BPC-157', 'Test')).rejects.toThrow('Invalid response format from AI');
  });

  it('throws error when API key is missing', async () => {
    delete import.meta.env.VITE_OPENAI_API_KEY;

    await expect(generateProtocolWithAI('BPC-157', 'Test')).rejects.toThrow('Missing VITE_OPENAI_API_KEY');
  });

  it('sends correct request body with product details', async () => {
    mockFetch.mockResolvedValueOnce({
      ok: true,
      json: async () => ({
        choices: [{ message: { content: JSON.stringify({ dosage: 'test' }) } }],
      }),
    });

    await generateProtocolWithAI('GHK-Cu', 'Copper peptide for skin');

    const callBody = JSON.parse(mockFetch.mock.calls[0][1].body);
    expect(callBody.model).toBe('gpt-3.5-turbo');
    expect(callBody.messages[0].role).toBe('system');
    expect(callBody.messages[1].content).toContain('GHK-Cu');
    expect(callBody.messages[1].content).toContain('Copper peptide for skin');
  });
});
