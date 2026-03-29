import { describe, it, expect, vi, beforeEach } from 'vitest';
import { renderHook, waitFor } from '@testing-library/react';
import { useShippingLocations } from '../useShippingLocations';

// Mock Supabase
const mockOrder = vi.fn();
const mockEq = vi.fn();
const mockSelect = vi.fn();

vi.mock('../../lib/supabase', () => ({
  supabase: {
    from: vi.fn(() => ({
      select: mockSelect,
    })),
  },
}));

describe('useShippingLocations', () => {
  const mockLocations = [
    { id: 'loc-1', name: 'LBC - Metro Manila', fee: 150, is_active: true, order_index: 1 },
    { id: 'loc-2', name: 'LBC - Provincial', fee: 200, is_active: true, order_index: 2 },
    { id: 'loc-3', name: 'Lalamove', fee: 0, is_active: true, order_index: 3 },
  ];

  beforeEach(() => {
    vi.clearAllMocks();

    mockSelect.mockReturnValue({
      eq: mockEq,
    });
    mockEq.mockReturnValue({
      order: mockOrder,
    });
  });

  describe('data fetching', () => {
    it('fetches and returns shipping locations from database', async () => {
      mockOrder.mockResolvedValue({
        data: mockLocations,
        error: null,
      });

      const { result } = renderHook(() => useShippingLocations());

      await waitFor(() => {
        expect(result.current.loading).toBe(false);
      });

      expect(result.current.locations).toEqual(mockLocations);
    });

    it('falls back to default locations on fetch error', async () => {
      mockOrder.mockResolvedValue({
        data: null,
        error: { message: 'Table not found' },
      });

      const { result } = renderHook(() => useShippingLocations());

      await waitFor(() => {
        expect(result.current.loading).toBe(false);
      });

      expect(result.current.locations).toHaveLength(3);
      expect(result.current.locations[0].name).toBe('LBC - Metro Manila');
    });

    it('falls back to defaults when data is empty', async () => {
      mockOrder.mockResolvedValue({
        data: [],
        error: null,
      });

      const { result } = renderHook(() => useShippingLocations());

      await waitFor(() => {
        expect(result.current.loading).toBe(false);
      });

      expect(result.current.locations).toHaveLength(3);
      expect(result.current.locations[0].id).toBe('LBC_METRO');
    });

    it('falls back to defaults on exception', async () => {
      mockOrder.mockRejectedValue(new Error('Network error'));

      const { result } = renderHook(() => useShippingLocations());

      await waitFor(() => {
        expect(result.current.loading).toBe(false);
      });

      expect(result.current.locations).toHaveLength(3);
    });
  });

  describe('getShippingFee', () => {
    it('returns correct fee for a known location', async () => {
      mockOrder.mockResolvedValue({
        data: mockLocations,
        error: null,
      });

      const { result } = renderHook(() => useShippingLocations());

      await waitFor(() => {
        expect(result.current.loading).toBe(false);
      });

      expect(result.current.getShippingFee('loc-1')).toBe(150);
      expect(result.current.getShippingFee('loc-2')).toBe(200);
      expect(result.current.getShippingFee('loc-3')).toBe(0);
    });

    it('returns 0 for unknown location', async () => {
      mockOrder.mockResolvedValue({
        data: mockLocations,
        error: null,
      });

      const { result } = renderHook(() => useShippingLocations());

      await waitFor(() => {
        expect(result.current.loading).toBe(false);
      });

      expect(result.current.getShippingFee('nonexistent')).toBe(0);
    });
  });
});
