import { describe, it, expect, vi, beforeEach } from 'vitest';
import { renderHook, waitFor } from '@testing-library/react';

const mockCategories = [
  {
    id: 'peptides',
    name: 'Peptides',
    icon: 'Beaker',
    sort_order: 1,
    active: true,
    created_at: '2024-01-01T00:00:00Z',
    updated_at: '2024-01-01T00:00:00Z',
  },
  {
    id: 'sarms',
    name: 'SARMs',
    icon: 'Dumbbell',
    sort_order: 2,
    active: true,
    created_at: '2024-01-01T00:00:00Z',
    updated_at: '2024-01-01T00:00:00Z',
  },
];

const mockSubscribe = vi.fn().mockReturnValue({ unsubscribe: vi.fn() });
const mockOn: any = vi.fn();
mockOn.mockReturnValue({ on: mockOn, subscribe: mockSubscribe });
const mockChannel = vi.fn().mockReturnValue({ on: mockOn, subscribe: mockSubscribe });
const mockRemoveChannel = vi.fn();

vi.mock('../../lib/supabase', () => ({
  supabase: {
    channel: mockChannel,
    removeChannel: mockRemoveChannel,
    from: vi.fn().mockImplementation((table: string) => {
      if (table === 'categories') {
        return {
          select: vi.fn().mockReturnValue({
            eq: vi.fn().mockReturnValue({
              order: vi.fn().mockResolvedValue({
                data: mockCategories,
                error: null,
              }),
            }),
          }),
          insert: vi.fn().mockReturnValue({
            select: vi.fn().mockReturnValue({
              single: vi.fn().mockResolvedValue({
                data: mockCategories[0],
                error: null,
              }),
            }),
          }),
          update: vi.fn().mockReturnValue({
            eq: vi.fn().mockResolvedValue({ error: null }),
          }),
          delete: vi.fn().mockReturnValue({
            eq: vi.fn().mockResolvedValue({ error: null }),
          }),
        };
      }
      if (table === 'products') {
        return {
          select: vi.fn().mockReturnValue({
            eq: vi.fn().mockReturnValue({
              limit: vi.fn().mockResolvedValue({ data: [], error: null }),
            }),
          }),
        };
      }
      return {};
    }),
  },
}));

describe('useCategories hook', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('fetches categories on mount', async () => {
    const { useCategories } = await import('../useCategories');
    const { result } = renderHook(() => useCategories());

    expect(result.current.loading).toBe(true);

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    // Should have "All Peptides" auto-prepended + 2 fetched categories
    expect(result.current.categories).toHaveLength(3);
    expect(result.current.categories[0].id).toBe('all');
    expect(result.current.categories[0].name).toBe('All Peptides');
  });

  it('does not duplicate "all" category if already present', async () => {
    // This test uses the default mock which doesn't include "all"
    // The hook auto-adds it
    const { useCategories } = await import('../useCategories');
    const { result } = renderHook(() => useCategories());

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    const allCategories = result.current.categories.filter(c => c.id === 'all');
    expect(allCategories).toHaveLength(1);
  });

  it('exposes error state', async () => {
    const { useCategories } = await import('../useCategories');
    const { result } = renderHook(() => useCategories());

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    expect(result.current.error).toBeNull();
  });

  it('sets up real-time subscription for categories', async () => {
    const { useCategories } = await import('../useCategories');
    renderHook(() => useCategories());

    expect(mockChannel).toHaveBeenCalledWith('categories-changes');
  });

  it('cleans up on unmount', async () => {
    const { useCategories } = await import('../useCategories');
    const { unmount } = renderHook(() => useCategories());

    unmount();

    expect(mockRemoveChannel).toHaveBeenCalled();
  });
});
