import { describe, it, expect, vi, beforeEach } from 'vitest';
import { renderHook, waitFor } from '@testing-library/react';
import { useSiteSettings } from '../useSiteSettings';

// Mock Supabase
const mockOrder = vi.fn();
const mockSelect = vi.fn();

vi.mock('../../lib/supabase', () => ({
  supabase: {
    from: vi.fn(() => ({
      select: mockSelect,
      update: vi.fn(() => ({
        eq: vi.fn().mockResolvedValue({ error: null }),
      })),
      upsert: vi.fn().mockResolvedValue({ error: null }),
    })),
  },
}));

describe('useSiteSettings', () => {
  const mockSettingsRows = [
    { id: 'site_name', value: 'TestPeptides', type: 'string', description: null, updated_at: '2024-01-01' },
    { id: 'site_logo', value: '/logo.png', type: 'string', description: null, updated_at: '2024-01-01' },
    { id: 'site_description', value: 'Test site', type: 'string', description: null, updated_at: '2024-01-01' },
    { id: 'currency', value: 'USD', type: 'string', description: null, updated_at: '2024-01-01' },
    { id: 'currency_code', value: 'USD', type: 'string', description: null, updated_at: '2024-01-01' },
    { id: 'hero_badge_text', value: 'Premium', type: 'string', description: null, updated_at: '2024-01-01' },
    { id: 'hero_title_prefix', value: 'Best', type: 'string', description: null, updated_at: '2024-01-01' },
    { id: 'hero_title_highlight', value: 'Peptides', type: 'string', description: null, updated_at: '2024-01-01' },
  ];

  beforeEach(() => {
    vi.clearAllMocks();

    mockSelect.mockReturnValue({
      order: mockOrder,
    });
  });

  it('fetches and transforms site settings on mount', async () => {
    mockOrder.mockResolvedValue({
      data: mockSettingsRows,
      error: null,
    });

    const { result } = renderHook(() => useSiteSettings());

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    expect(result.current.siteSettings).toBeTruthy();
    expect(result.current.siteSettings!.site_name).toBe('TestPeptides');
    expect(result.current.siteSettings!.site_logo).toBe('/logo.png');
    expect(result.current.siteSettings!.currency).toBe('USD');
    expect(result.current.siteSettings!.hero_title_highlight).toBe('Peptides');
    expect(result.current.error).toBeNull();
  });

  it('uses default values when settings are missing', async () => {
    mockOrder.mockResolvedValue({
      data: [],
      error: null,
    });

    const { result } = renderHook(() => useSiteSettings());

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    expect(result.current.siteSettings!.site_name).toBe('RSPEPTIDE');
    expect(result.current.siteSettings!.currency).toBe('USD');
    expect(result.current.siteSettings!.hero_badge_text).toBe('Premium Peptide Solutions');
  });

  it('handles fetch errors', async () => {
    mockOrder.mockResolvedValue({
      data: null,
      error: new Error('Network error'),
    });

    const { result } = renderHook(() => useSiteSettings());

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    expect(result.current.error).toBeTruthy();
    expect(result.current.siteSettings).toBeNull();
  });

  it('sets loading state during fetch', () => {
    mockOrder.mockResolvedValue({
      data: [],
      error: null,
    });

    const { result } = renderHook(() => useSiteSettings());
    expect(result.current.loading).toBe(true);
  });
});
