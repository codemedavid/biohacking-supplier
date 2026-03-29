import { describe, it, expect, vi, beforeEach } from 'vitest';
import { renderHook, waitFor, act } from '@testing-library/react';
import { usePaymentMethods } from '../usePaymentMethods';

// Mock Supabase
const mockSelect = vi.fn();
const mockEq = vi.fn();
const mockOrder = vi.fn();
const mockInsert = vi.fn();
const mockUpdate = vi.fn();
const mockDelete = vi.fn();
const mockSingle = vi.fn();

vi.mock('../../lib/supabase', () => ({
  supabase: {
    from: vi.fn(() => ({
      select: mockSelect,
      insert: mockInsert,
      update: mockUpdate,
      delete: mockDelete,
    })),
  },
}));

describe('usePaymentMethods', () => {
  const mockPaymentMethods = [
    {
      id: 'pm-1',
      name: 'GCash',
      account_number: '09171234567',
      account_name: 'Juan Cruz',
      qr_code_url: 'https://example.com/qr.png',
      active: true,
      sort_order: 1,
      created_at: '2024-01-01',
      updated_at: '2024-01-01',
    },
    {
      id: 'pm-2',
      name: 'BDO',
      account_number: '123456789',
      account_name: 'Juan Cruz',
      qr_code_url: 'https://example.com/qr2.png',
      active: true,
      sort_order: 2,
      created_at: '2024-01-01',
      updated_at: '2024-01-01',
    },
  ];

  beforeEach(() => {
    vi.clearAllMocks();

    // Default: successful fetch of active payment methods
    mockSelect.mockReturnValue({
      eq: mockEq,
    });
    mockEq.mockReturnValue({
      order: mockOrder,
    });
    mockOrder.mockResolvedValue({
      data: mockPaymentMethods,
      error: null,
    });
  });

  it('fetches payment methods on mount', async () => {
    const { result } = renderHook(() => usePaymentMethods());

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    expect(result.current.paymentMethods).toEqual(mockPaymentMethods);
    expect(result.current.error).toBeNull();
  });

  it('sets loading state during fetch', () => {
    const { result } = renderHook(() => usePaymentMethods());
    expect(result.current.loading).toBe(true);
  });

  it('handles fetch errors', async () => {
    mockOrder.mockResolvedValue({
      data: null,
      error: new Error('Network error'),
    });

    const { result } = renderHook(() => usePaymentMethods());

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    expect(result.current.error).toBeTruthy();
    expect(result.current.paymentMethods).toEqual([]);
  });

  it('handles empty payment methods response', async () => {
    mockOrder.mockResolvedValue({
      data: [],
      error: null,
    });

    const { result } = renderHook(() => usePaymentMethods());

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    expect(result.current.paymentMethods).toEqual([]);
  });
});
