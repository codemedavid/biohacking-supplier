import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import OrdersManager from '../OrdersManager';

// ── Test Data ──────────────────────────────────────────────────────

const makeOrder = (overrides: Record<string, unknown> = {}) => ({
  id: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
  customer_name: 'Juan Dela Cruz',
  customer_email: 'juan@gmail.com',
  customer_phone: '09171234567',
  shipping_address: '123 Main St',
  shipping_barangay: 'San Antonio',
  shipping_city: 'Makati',
  shipping_state: 'Metro Manila',
  shipping_zip_code: '1200',
  shipping_country: 'Philippines',
  shipping_location: 'NCR',
  shipping_fee: 150,
  order_items: [
    {
      product_id: 'prod-1',
      product_name: 'BPC-157',
      variation_id: 'var-1',
      variation_name: '5mg',
      quantity: 2,
      price: 1500,
      total: 3000,
    },
  ],
  total_price: 3000,
  payment_method_id: 'pm-gcash',
  payment_method_name: 'GCash',
  payment_proof_url: null,
  contact_method: 'whatsapp',
  order_status: 'new',
  payment_status: 'pending',
  notes: null,
  created_at: '2024-06-01T10:00:00Z',
  updated_at: '2024-06-01T10:00:00Z',
  tracking_number: null,
  shipping_provider: null,
  shipping_note: null,
  promo_code: null,
  discount_applied: null,
  ...overrides,
});

const makeOrderWithProductStock = (overrides: Record<string, unknown> = {}) =>
  makeOrder({
    order_items: [
      {
        product_id: 'prod-1',
        product_name: 'BPC-157',
        variation_id: null,
        variation_name: null,
        quantity: 3,
        price: 2500,
        total: 7500,
      },
    ],
    total_price: 7500,
    ...overrides,
  });

// ── Mocks ──────────────────────────────────────────────────────────

const mockRefreshProducts = vi.fn();

vi.mock('../../hooks/useMenu', () => ({
  useMenu: () => ({
    products: [],
    loading: false,
    error: null,
    refreshProducts: mockRefreshProducts,
  }),
}));

vi.mock('../../lib/posthog', () => ({
  default: {
    capture: vi.fn(),
    identify: vi.fn(),
    people: { set: vi.fn() },
  },
}));

// Supabase mock helpers
let mockOrdersData: ReturnType<typeof makeOrder>[] = [];
let mockVariationStockMap: Record<string, number> = {};
let mockProductStockMap: Record<string, number> = {};
let mockUpdateCalls: Array<{ table: string; data: Record<string, unknown>; id: string }> = [];

const buildSupabaseMock = () => {
  const mockFrom = vi.fn().mockImplementation((table: string) => {
    if (table === 'orders') {
      return {
        select: vi.fn().mockReturnValue({
          order: vi.fn().mockResolvedValue({ data: mockOrdersData, error: null }),
        }),
        update: vi.fn().mockImplementation((data: Record<string, unknown>) => ({
          eq: vi.fn().mockImplementation((_col: string, id: string) => {
            mockUpdateCalls.push({ table: 'orders', data, id });
            mockOrdersData = mockOrdersData.map(o =>
              o.id === id ? { ...o, ...data } : o
            );
            return Promise.resolve({ error: null });
          }),
        })),
      };
    }
    if (table === 'product_variations') {
      return {
        select: vi.fn().mockReturnValue({
          eq: vi.fn().mockImplementation((_col: string, id: string) => ({
            single: vi.fn().mockResolvedValue({
              data: { stock_quantity: mockVariationStockMap[id] ?? 20 },
              error: null,
            }),
          })),
        }),
        update: vi.fn().mockImplementation((data: Record<string, unknown>) => ({
          eq: vi.fn().mockImplementation((_col: string, id: string) => {
            mockUpdateCalls.push({ table: 'product_variations', data, id });
            if (typeof data.stock_quantity === 'number') {
              mockVariationStockMap[id] = data.stock_quantity;
            }
            return Promise.resolve({ error: null });
          }),
        })),
      };
    }
    if (table === 'products') {
      return {
        select: vi.fn().mockReturnValue({
          eq: vi.fn().mockImplementation((_col: string, id: string) => ({
            single: vi.fn().mockResolvedValue({
              data: { stock_quantity: mockProductStockMap[id] ?? 50 },
              error: null,
            }),
          })),
        }),
        update: vi.fn().mockImplementation((data: Record<string, unknown>) => ({
          eq: vi.fn().mockImplementation((_col: string, id: string) => {
            mockUpdateCalls.push({ table: 'products', data, id });
            if (typeof data.stock_quantity === 'number') {
              mockProductStockMap[id] = data.stock_quantity;
            }
            return Promise.resolve({ error: null });
          }),
        })),
      };
    }
    return {
      select: vi.fn().mockReturnValue({
        order: vi.fn().mockResolvedValue({ data: [], error: null }),
        eq: vi.fn().mockReturnValue({
          single: vi.fn().mockResolvedValue({ data: null, error: null }),
        }),
      }),
      update: vi.fn().mockReturnValue({
        eq: vi.fn().mockResolvedValue({ error: null }),
      }),
    };
  });

  return { from: mockFrom };
};

let mockSupabase: ReturnType<typeof buildSupabaseMock>;

vi.mock('../../lib/supabase', () => ({
  get supabase() {
    return mockSupabase;
  },
}));

const confirmMock = vi.fn().mockReturnValue(true);
const alertMock = vi.fn();
global.confirm = confirmMock;
global.alert = alertMock;

const dispatchEventSpy = vi.spyOn(window, 'dispatchEvent').mockImplementation(() => true);

// ── Setup ──────────────────────────────────────────────────────────

beforeEach(() => {
  vi.clearAllMocks();
  mockOrdersData = [];
  mockVariationStockMap = {};
  mockProductStockMap = {};
  mockUpdateCalls = [];
  mockSupabase = buildSupabaseMock();
  confirmMock.mockReturnValue(true);
});

const renderManager = () => render(<OrdersManager onBack={vi.fn()} />);

// Helper to get the status dropdown by its aria-label
const getStatusDropdown = () => screen.getByLabelText('Order Status') as HTMLSelectElement;

async function openOrderDetails() {
  await waitFor(() => {
    expect(screen.getByText('View Details')).toBeInTheDocument();
  });
  fireEvent.click(screen.getByText('View Details'));
  await waitFor(() => {
    expect(screen.getByText('Customer Information')).toBeInTheDocument();
  });
}

// ══════════════════════════════════════════════════════════════════
// UNIT TESTS
// ══════════════════════════════════════════════════════════════════

describe('OrdersManager - Unit Tests', () => {
  describe('Order list rendering', () => {
    it('shows loading state initially', () => {
      renderManager();
      expect(screen.getByText(/Loading orders/i)).toBeInTheDocument();
    });

    it('renders empty state when no orders exist', async () => {
      mockOrdersData = [];
      renderManager();
      await waitFor(() => {
        expect(screen.getByText('No orders found')).toBeInTheDocument();
      });
    });

    it('renders order cards with correct data', async () => {
      mockOrdersData = [makeOrder()];
      renderManager();
      await waitFor(() => {
        expect(screen.getByText(/AAAAAAAA/i)).toBeInTheDocument();
        expect(screen.getByText('Juan Dela Cruz')).toBeInTheDocument();
        expect(screen.getByText('juan@gmail.com')).toBeInTheDocument();
      });
    });

    it('displays status filter buttons with correct counts', async () => {
      mockOrdersData = [
        makeOrder({ id: 'a1', order_status: 'new' }),
        makeOrder({ id: 'a2', order_status: 'new' }),
        makeOrder({ id: 'a3', order_status: 'confirmed' }),
        makeOrder({ id: 'a4', order_status: 'shipped' }),
        makeOrder({ id: 'a5', order_status: 'delivered' }),
      ];
      renderManager();
      await waitFor(() => {
        expect(screen.getByText('All Orders')).toBeInTheDocument();
      });
      // Total = 5
      expect(screen.getByText('5')).toBeInTheDocument();
    });
  });

  describe('Search and filtering', () => {
    it('filters orders by customer name', async () => {
      mockOrdersData = [
        makeOrder({ id: 'a1', customer_name: 'Alice' }),
        makeOrder({ id: 'a2', customer_name: 'Bob' }),
      ];
      const user = userEvent.setup();
      renderManager();

      await waitFor(() => {
        expect(screen.getByText('Alice')).toBeInTheDocument();
      });

      const searchInput = screen.getByPlaceholderText(/Search by customer name/i);
      await user.type(searchInput, 'Alice');

      expect(screen.getByText('Alice')).toBeInTheDocument();
      expect(screen.queryByText('Bob')).not.toBeInTheDocument();
    });

    it('filters by status when clicking status filter buttons', async () => {
      mockOrdersData = [
        makeOrder({ id: 'a1', order_status: 'new', customer_name: 'New Customer' }),
        makeOrder({ id: 'a2', order_status: 'delivered', customer_name: 'Done Customer' }),
      ];
      renderManager();

      await waitFor(() => {
        expect(screen.getByText('New Customer')).toBeInTheDocument();
      });

      // The stats card buttons have the status text as a <p> child.
      // Use getAllByText and click the one that is a <p> within a <button>
      const deliveredButtons = screen.getAllByText('Delivered');
      // Find the one that's in the filter section (it's a <p> tag)
      const filterButton = deliveredButtons.find(
        el => el.tagName === 'P' && el.closest('button')
      );
      expect(filterButton).toBeDefined();
      fireEvent.click(filterButton!.closest('button')!);

      await waitFor(() => {
        expect(screen.queryByText('New Customer')).not.toBeInTheDocument();
        expect(screen.getByText('Done Customer')).toBeInTheDocument();
      });
    });
  });

  describe('Status dropdown rendering', () => {
    it('shows status dropdown in order details with correct value', async () => {
      mockOrdersData = [makeOrder()];
      renderManager();
      await openOrderDetails();

      const dropdown = getStatusDropdown();
      expect(dropdown).toBeInTheDocument();
      expect(dropdown.value).toBe('new');
    });

    it('shows all six status options', async () => {
      mockOrdersData = [makeOrder()];
      renderManager();
      await openOrderDetails();

      const dropdown = getStatusDropdown();
      const options = Array.from(dropdown.options).map(o => o.value);
      expect(options).toEqual(['new', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled']);
    });

    it('shows stock deduction hint for new orders', async () => {
      mockOrdersData = [makeOrder()];
      renderManager();
      await openOrderDetails();

      expect(screen.getByText(/Selecting "Confirmed" will deduct stock/i)).toBeInTheDocument();
    });

    it('hides stock deduction hint for non-new orders', async () => {
      mockOrdersData = [makeOrder({ order_status: 'confirmed' })];
      renderManager();
      await openOrderDetails();

      expect(screen.queryByText(/Selecting "Confirmed" will deduct stock/i)).not.toBeInTheDocument();
    });

    it('disables dropdown for delivered orders with final label', async () => {
      mockOrdersData = [makeOrder({ order_status: 'delivered' })];
      renderManager();
      await openOrderDetails();

      expect(getStatusDropdown()).toBeDisabled();
      expect(screen.getByText('Status is final')).toBeInTheDocument();
    });

    it('disables dropdown for cancelled orders with final label', async () => {
      mockOrdersData = [makeOrder({ order_status: 'cancelled' })];
      renderManager();
      await openOrderDetails();

      expect(getStatusDropdown()).toBeDisabled();
      expect(screen.getByText('Status is final')).toBeInTheDocument();
    });

    it('reflects current status value for processing order', async () => {
      mockOrdersData = [makeOrder({ order_status: 'processing' })];
      renderManager();
      await openOrderDetails();

      expect(getStatusDropdown().value).toBe('processing');
    });
  });
});

// ══════════════════════════════════════════════════════════════════
// INTEGRATION TESTS
// ══════════════════════════════════════════════════════════════════

describe('OrdersManager - Integration Tests', () => {
  describe('Confirm order with stock deduction (variation items)', () => {
    it('deducts variation stock when confirming a new order', async () => {
      mockOrdersData = [makeOrder()];
      mockVariationStockMap['var-1'] = 20;
      renderManager();
      await openOrderDetails();

      fireEvent.change(getStatusDropdown(), { target: { value: 'confirmed' } });

      await waitFor(() => {
        expect(confirmMock).toHaveBeenCalledWith(
          expect.stringContaining('Confirm order')
        );
      });

      await waitFor(() => {
        const varUpdate = mockUpdateCalls.find(
          c => c.table === 'product_variations' && c.id === 'var-1'
        );
        expect(varUpdate).toBeDefined();
        expect(varUpdate!.data.stock_quantity).toBe(18); // 20 - 2
      });

      await waitFor(() => {
        const orderUpdate = mockUpdateCalls.find(
          c => c.table === 'orders' && c.data.order_status === 'confirmed'
        );
        expect(orderUpdate).toBeDefined();
        expect(orderUpdate!.data.payment_status).toBe('paid');
      });

      expect(mockRefreshProducts).toHaveBeenCalled();
      expect(dispatchEventSpy).toHaveBeenCalledWith(
        expect.objectContaining({ type: 'orderConfirmed' })
      );
      expect(alertMock).toHaveBeenCalledWith(
        expect.stringContaining('Stock has been deducted')
      );
    });

    it('deducts product stock when item has no variation', async () => {
      mockOrdersData = [makeOrderWithProductStock()];
      mockProductStockMap['prod-1'] = 50;
      renderManager();
      await openOrderDetails();

      fireEvent.change(getStatusDropdown(), { target: { value: 'confirmed' } });

      await waitFor(() => {
        const prodUpdate = mockUpdateCalls.find(
          c => c.table === 'products' && c.id === 'prod-1'
        );
        expect(prodUpdate).toBeDefined();
        expect(prodUpdate!.data.stock_quantity).toBe(47); // 50 - 3
      });
    });

    it('aborts with alert when variation stock is insufficient', async () => {
      mockOrdersData = [makeOrder()];
      mockVariationStockMap['var-1'] = 1; // needs 2
      renderManager();
      await openOrderDetails();

      fireEvent.change(getStatusDropdown(), { target: { value: 'confirmed' } });

      await waitFor(() => {
        expect(alertMock).toHaveBeenCalledWith(
          expect.stringContaining('Insufficient stock')
        );
      });

      expect(mockUpdateCalls.find(c => c.table === 'orders')).toBeUndefined();
    });

    it('aborts with alert when product stock is insufficient', async () => {
      mockOrdersData = [makeOrderWithProductStock()];
      mockProductStockMap['prod-1'] = 1; // needs 3
      renderManager();
      await openOrderDetails();

      fireEvent.change(getStatusDropdown(), { target: { value: 'confirmed' } });

      await waitFor(() => {
        expect(alertMock).toHaveBeenCalledWith(
          expect.stringContaining('Insufficient stock')
        );
      });

      expect(mockUpdateCalls.find(c => c.table === 'orders')).toBeUndefined();
    });

    it('does nothing when user declines confirm dialog', async () => {
      confirmMock.mockReturnValue(false);
      mockOrdersData = [makeOrder()];
      renderManager();
      await openOrderDetails();

      fireEvent.change(getStatusDropdown(), { target: { value: 'confirmed' } });

      await waitFor(() => {
        expect(confirmMock).toHaveBeenCalled();
      });

      expect(mockUpdateCalls).toHaveLength(0);
    });
  });

  describe('Status transitions via dropdown', () => {
    it('confirmed -> processing', async () => {
      mockOrdersData = [makeOrder({ order_status: 'confirmed', payment_status: 'paid' })];
      renderManager();
      await openOrderDetails();

      fireEvent.change(getStatusDropdown(), { target: { value: 'processing' } });

      await waitFor(() => {
        expect(confirmMock).toHaveBeenCalledWith(
          expect.stringContaining('confirmed')
        );
      });

      await waitFor(() => {
        const upd = mockUpdateCalls.find(c => c.data.order_status === 'processing');
        expect(upd).toBeDefined();
      });
    });

    it('processing -> shipped', async () => {
      mockOrdersData = [makeOrder({ order_status: 'processing' })];
      renderManager();
      await openOrderDetails();

      fireEvent.change(getStatusDropdown(), { target: { value: 'shipped' } });

      await waitFor(() => {
        const upd = mockUpdateCalls.find(c => c.data.order_status === 'shipped');
        expect(upd).toBeDefined();
      });
    });

    it('shipped -> delivered', async () => {
      mockOrdersData = [makeOrder({ order_status: 'shipped' })];
      renderManager();
      await openOrderDetails();

      fireEvent.change(getStatusDropdown(), { target: { value: 'delivered' } });

      await waitFor(() => {
        const upd = mockUpdateCalls.find(c => c.data.order_status === 'delivered');
        expect(upd).toBeDefined();
      });
    });

    it('no-op when selecting the same status', async () => {
      mockOrdersData = [makeOrder({ order_status: 'processing' })];
      renderManager();
      await openOrderDetails();

      fireEvent.change(getStatusDropdown(), { target: { value: 'processing' } });

      expect(confirmMock).not.toHaveBeenCalled();
      expect(mockUpdateCalls).toHaveLength(0);
    });

    it('no update when user declines dialog', async () => {
      confirmMock.mockReturnValue(false);
      mockOrdersData = [makeOrder({ order_status: 'confirmed' })];
      renderManager();
      await openOrderDetails();

      fireEvent.change(getStatusDropdown(), { target: { value: 'processing' } });

      await waitFor(() => {
        expect(confirmMock).toHaveBeenCalled();
      });

      expect(mockUpdateCalls).toHaveLength(0);
    });
  });

  describe('Cancel order via dropdown', () => {
    it('shows specific cancel confirmation dialog', async () => {
      mockOrdersData = [makeOrder({ order_status: 'confirmed' })];
      renderManager();
      await openOrderDetails();

      fireEvent.change(getStatusDropdown(), { target: { value: 'cancelled' } });

      await waitFor(() => {
        expect(confirmMock).toHaveBeenCalledWith(
          'Are you sure you want to cancel this order?'
        );
      });
    });

    it('cancels order when user confirms', async () => {
      mockOrdersData = [makeOrder({ order_status: 'confirmed' })];
      renderManager();
      await openOrderDetails();

      fireEvent.change(getStatusDropdown(), { target: { value: 'cancelled' } });

      await waitFor(() => {
        const upd = mockUpdateCalls.find(c => c.data.order_status === 'cancelled');
        expect(upd).toBeDefined();
      });
    });

    it('does not cancel when user declines', async () => {
      confirmMock.mockReturnValue(false);
      mockOrdersData = [makeOrder({ order_status: 'confirmed' })];
      renderManager();
      await openOrderDetails();

      fireEvent.change(getStatusDropdown(), { target: { value: 'cancelled' } });

      await waitFor(() => {
        expect(confirmMock).toHaveBeenCalled();
      });

      expect(mockUpdateCalls).toHaveLength(0);
    });
  });

  describe('PostHog analytics', () => {
    it('fires BS_order_confirmed on confirm', async () => {
      const posthog = (await import('../../lib/posthog')).default;
      mockOrdersData = [makeOrder()];
      mockVariationStockMap['var-1'] = 20;
      renderManager();
      await openOrderDetails();

      fireEvent.change(getStatusDropdown(), { target: { value: 'confirmed' } });

      await waitFor(() => {
        expect(posthog.capture).toHaveBeenCalledWith('BS_order_confirmed', expect.objectContaining({
          order_id: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
          customer_email: 'juan@gmail.com',
          customer_name: 'Juan Dela Cruz',
          total_price: 3000,
        }));
      });
    });

    it('fires BS_order_shipped on shipped transition', async () => {
      const posthog = (await import('../../lib/posthog')).default;
      mockOrdersData = [makeOrder({ order_status: 'processing' })];
      renderManager();
      await openOrderDetails();

      fireEvent.change(getStatusDropdown(), { target: { value: 'shipped' } });

      await waitFor(() => {
        expect(posthog.capture).toHaveBeenCalledWith('BS_order_shipped', expect.objectContaining({
          order_id: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
        }));
      });
    });
  });

  describe('Tracking information', () => {
    it('saves tracking info successfully', async () => {
      const user = userEvent.setup();
      mockOrdersData = [makeOrder({ order_status: 'shipped' })];
      renderManager();
      await openOrderDetails();

      const trackingInput = screen.getByPlaceholderText(/Enter tracking number/i);
      await user.type(trackingInput, 'TRACK123456');

      fireEvent.click(screen.getByText('Save Tracking Info'));

      await waitFor(() => {
        const upd = mockUpdateCalls.find(
          c => c.table === 'orders' && c.data.tracking_number === 'TRACK123456'
        );
        expect(upd).toBeDefined();
      });

      expect(alertMock).toHaveBeenCalledWith('Tracking information saved successfully!');
    });
  });

  describe('Order detail view navigation', () => {
    it('opens detail view when clicking View Details', async () => {
      mockOrdersData = [makeOrder()];
      renderManager();
      await openOrderDetails();

      expect(screen.getByText('Customer Information')).toBeInTheDocument();
      expect(screen.getByText('Juan Dela Cruz')).toBeInTheDocument();
    });

    it('returns to list when clicking Back to Orders', async () => {
      mockOrdersData = [makeOrder()];
      renderManager();
      await openOrderDetails();

      fireEvent.click(screen.getByText('Back to Orders'));

      await waitFor(() => {
        expect(screen.getByText('Orders Management')).toBeInTheDocument();
      });
    });
  });

  describe('Multiple order items stock deduction', () => {
    it('deducts stock for both variation and product items', async () => {
      const multiItemOrder = makeOrder({
        order_items: [
          {
            product_id: 'prod-1',
            product_name: 'BPC-157',
            variation_id: 'var-1',
            variation_name: '5mg',
            quantity: 2,
            price: 1500,
            total: 3000,
          },
          {
            product_id: 'prod-2',
            product_name: 'TB-500',
            variation_id: null,
            variation_name: null,
            quantity: 1,
            price: 2500,
            total: 2500,
          },
        ],
        total_price: 5500,
      });
      mockOrdersData = [multiItemOrder];
      mockVariationStockMap['var-1'] = 10;
      mockProductStockMap['prod-2'] = 30;
      renderManager();
      await openOrderDetails();

      fireEvent.change(getStatusDropdown(), { target: { value: 'confirmed' } });

      await waitFor(() => {
        const varUpdate = mockUpdateCalls.find(
          c => c.table === 'product_variations' && c.id === 'var-1'
        );
        expect(varUpdate).toBeDefined();
        expect(varUpdate!.data.stock_quantity).toBe(8); // 10 - 2

        const prodUpdate = mockUpdateCalls.find(
          c => c.table === 'products' && c.id === 'prod-2'
        );
        expect(prodUpdate).toBeDefined();
        expect(prodUpdate!.data.stock_quantity).toBe(29); // 30 - 1
      });
    });
  });
});
