import { describe, it, expect, vi, beforeEach } from 'vitest';
import { renderHook, waitFor } from '@testing-library/react';
import { useCouriers } from '../useCouriers';

// Mock Supabase
const mockOrder = vi.fn();
const mockSelect = vi.fn();
const mockEq = vi.fn();
const mockSingle = vi.fn();

vi.mock('../../lib/supabase', () => ({
  supabase: {
    from: vi.fn(() => ({
      select: mockSelect,
      insert: vi.fn(() => ({
        select: vi.fn(() => ({
          single: mockSingle,
        })),
      })),
      update: vi.fn(() => ({
        eq: vi.fn(() => ({
          select: vi.fn(() => ({
            single: mockSingle,
          })),
        })),
      })),
      delete: vi.fn(() => ({
        eq: mockEq,
      })),
    })),
  },
}));

describe('useCouriers', () => {
  const mockCourierData = [
    { id: 'c-1', name: 'LBC Express', code: 'lbc', tracking_url_template: 'https://lbc.com/track/{tracking}', is_active: true, sort_order: 1, created_at: '2024-01-01' },
    { id: 'c-2', name: 'Lalamove', code: 'lalamove', tracking_url_template: null, is_active: true, sort_order: 2, created_at: '2024-01-01' },
  ];

  beforeEach(() => {
    vi.clearAllMocks();
    mockSelect.mockReturnValue({
      order: mockOrder,
    });
  });

  it('fetches couriers on mount', async () => {
    mockOrder.mockResolvedValue({
      data: mockCourierData,
      error: null,
    });

    const { result } = renderHook(() => useCouriers());

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    expect(result.current.couriers).toEqual(mockCourierData);
  });

  it('sets loading state during fetch', () => {
    mockOrder.mockResolvedValue({
      data: [],
      error: null,
    });

    const { result } = renderHook(() => useCouriers());
    expect(result.current.loading).toBe(true);
  });

  it('falls back to default couriers on error', async () => {
    mockOrder.mockRejectedValue(new Error('Table not found'));

    const { result } = renderHook(() => useCouriers());

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    expect(result.current.couriers).toHaveLength(3);
    expect(result.current.couriers[0].name).toBe('LBC Express');
    expect(result.current.couriers[1].name).toBe('Lalamove');
    expect(result.current.couriers[2].name).toBe('Maxim');
  });

  it('handles empty response', async () => {
    mockOrder.mockResolvedValue({
      data: [],
      error: null,
    });

    const { result } = renderHook(() => useCouriers());

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    expect(result.current.couriers).toEqual([]);
  });

  it('handles null data with fallback', async () => {
    mockOrder.mockResolvedValue({
      data: null,
      error: null,
    });

    const { result } = renderHook(() => useCouriers());

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    expect(result.current.couriers).toEqual([]);
  });
});
