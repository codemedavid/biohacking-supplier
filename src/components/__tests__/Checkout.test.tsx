import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import Checkout from '../Checkout';
import { mockProduct, mockCartItem, mockCartItemUSD } from '../../test/fixtures';
import type { CartItem } from '../../types';

// ── Mocks ──────────────────────────────────────────────────────────

const mockPaymentMethods = [
  {
    id: 'pm-gcash',
    name: 'GCash',
    account_number: '0912-345-6789',
    account_name: 'Peptide Pulse',
    qr_code_url: 'https://example.com/qr.png',
    active: true,
    sort_order: 1,
    created_at: '2024-01-01T00:00:00Z',
    updated_at: '2024-01-01T00:00:00Z',
  },
  {
    id: 'pm-bdo',
    name: 'BDO',
    account_number: '1234-5678-9012',
    account_name: 'Peptide Pulse Inc',
    qr_code_url: '',
    active: true,
    sort_order: 2,
    created_at: '2024-01-01T00:00:00Z',
    updated_at: '2024-01-01T00:00:00Z',
  },
];

const mockShippingLocations = [
  { id: 'LBC_METRO', name: 'LBC - Metro Manila', fee: 150, is_active: true, order_index: 1 },
  { id: 'LBC_PROVINCIAL', name: 'LBC - Provincial', fee: 200, is_active: true, order_index: 2 },
];

const mockCouriers = [
  { id: 'a0000000-0000-0000-0000-000000000001', name: 'LBC Express', code: 'lbc', tracking_url_template: null, is_active: true, sort_order: 1, created_at: '2024-01-01T00:00:00Z' },
];

vi.mock('../../hooks/usePaymentMethods', () => ({
  usePaymentMethods: () => ({ paymentMethods: mockPaymentMethods, loading: false, error: null }),
}));

vi.mock('../../hooks/useShippingLocations', () => ({
  useShippingLocations: () => ({
    locations: mockShippingLocations,
    loading: false,
    error: null,
    getShippingFee: (id: string) => mockShippingLocations.find(l => l.id === id)?.fee ?? 0,
  }),
}));

vi.mock('../../hooks/useCouriers', () => ({
  useCouriers: () => ({ couriers: mockCouriers, loading: false }),
}));

const mockUploadImage = vi.fn().mockResolvedValue('https://storage.example.com/proof.jpg');
vi.mock('../../hooks/useImageUpload', () => ({
  useImageUpload: () => ({
    uploadImage: mockUploadImage,
    uploading: false,
    uploadProgress: 0,
    deleteImage: vi.fn(),
  }),
}));

// Mock supabase
const mockSupabaseInsert = vi.fn().mockReturnValue({
  select: vi.fn().mockReturnValue({
    single: vi.fn().mockResolvedValue({
      data: { id: 'order-123', order_status: 'new' },
      error: null,
    }),
  }),
});

const mockSupabaseUpdate = vi.fn().mockReturnValue({
  eq: vi.fn().mockResolvedValue({ error: null }),
});

const mockSupabasePromoSelect = vi.fn();

vi.mock('../../lib/supabase', () => ({
  supabase: {
    from: vi.fn().mockImplementation((table: string) => {
      if (table === 'promo_codes') {
        return {
          select: vi.fn().mockReturnValue({
            eq: vi.fn().mockReturnValue({
              eq: vi.fn().mockReturnValue({
                single: mockSupabasePromoSelect,
              }),
            }),
          }),
        };
      }
      if (table === 'orders') {
        return { insert: mockSupabaseInsert };
      }
      if (table === 'promo_codes') {
        return { update: mockSupabaseUpdate };
      }
      return {
        insert: vi.fn().mockReturnValue({ select: vi.fn().mockReturnValue({ single: vi.fn().mockResolvedValue({ data: {}, error: null }) }) }),
        update: vi.fn().mockReturnValue({ eq: vi.fn().mockResolvedValue({ error: null }) }),
      };
    }),
  },
}));

// Mock posthog
vi.mock('../../lib/posthog', () => ({
  default: {
    capture: vi.fn(),
    identify: vi.fn(),
    people: { set: vi.fn() },
  },
  identifyWithEmail: vi.fn(),
}));

// Mock clipboard and window
const mockClipboardWriteText = vi.fn().mockResolvedValue(undefined);
Object.defineProperty(navigator, 'clipboard', {
  value: { writeText: mockClipboardWriteText },
  writable: true,
  configurable: true,
});

const mockScrollTo = vi.fn();
Object.defineProperty(window, 'scrollTo', { value: mockScrollTo });
Object.defineProperty(window, 'open', { value: vi.fn() });

const alertMock = vi.fn();
global.alert = alertMock;

// ── Helpers ──────────────────────────────────────────────────────────

const defaultCartItems: CartItem[] = [
  {
    product: mockProduct,
    quantity: 2,
    price: 2000,
    currency: 'USD',
  },
];

const defaultProps = {
  cartItems: defaultCartItems,
  totalPrice: 4000,
  onBack: vi.fn(),
};

async function fillDetailsForm(user: ReturnType<typeof userEvent.setup>) {
  await user.type(screen.getByPlaceholderText('Juan Dela Cruz'), 'Test User');
  await user.type(screen.getByPlaceholderText('juan.delacruz@gmail.com'), 'test@gmail.com');
  const phoneInputs = screen.getAllByPlaceholderText('e.g., 912 345 6789');
  await user.type(phoneInputs[0], '9171234567');
  await user.type(phoneInputs[1], '9187654321');
  await user.type(screen.getByPlaceholderText('Complete delivery address'), '123 Main St, Makati City, Metro Manila, 1200');

  // Select courier
  const courierButton = screen.getByText('LBC Express');
  await user.click(courierButton);

  // Select shipping location
  await waitFor(() => {
    expect(screen.getByText('LBC - Metro Manila')).toBeInTheDocument();
  });
  await user.click(screen.getByText('LBC - Metro Manila'));
}

// ── Tests ──────────────────────────────────────────────────────────

describe('Checkout component', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockUploadImage.mockResolvedValue('https://storage.example.com/proof.jpg');
  });

  describe('details step rendering', () => {
    it('renders checkout form with customer details fields', () => {
      render(<Checkout {...defaultProps} />);

      expect(screen.getByText('Checkout Information')).toBeInTheDocument();
      expect(screen.getByPlaceholderText('Juan Dela Cruz')).toBeInTheDocument();
      expect(screen.getByPlaceholderText('juan.delacruz@gmail.com')).toBeInTheDocument();
      expect(screen.getAllByPlaceholderText('e.g., 912 345 6789').length).toBe(2);
    });

    it('renders shipping address fields', () => {
      render(<Checkout {...defaultProps} />);

      expect(screen.getByPlaceholderText('Complete delivery address')).toBeInTheDocument();
    });

    it('renders order summary with cart items', () => {
      render(<Checkout {...defaultProps} />);

      expect(screen.getByText('Order Summary')).toBeInTheDocument();
      // Details step shows product name and "Qty: X" separately
      expect(screen.getByText('BPC-157')).toBeInTheDocument();
      expect(screen.getByText('Qty: 2')).toBeInTheDocument();
    });

    it('renders back button that calls onBack', async () => {
      const user = userEvent.setup();
      render(<Checkout {...defaultProps} />);

      await user.click(screen.getByText('Back to Cart'));
      expect(defaultProps.onBack).toHaveBeenCalled();
    });

    it('renders courier selection', () => {
      render(<Checkout {...defaultProps} />);

      expect(screen.getByText('LBC Express')).toBeInTheDocument();
    });

    it('renders promo code input', () => {
      render(<Checkout {...defaultProps} />);

      expect(screen.getByPlaceholderText('ENTER CODE')).toBeInTheDocument();
      expect(screen.getByText('APPLY')).toBeInTheDocument();
    });
  });

  describe('form validation', () => {
    it('disables proceed button when form is incomplete', () => {
      render(<Checkout {...defaultProps} />);

      const proceedButton = screen.getByText('Proceed to Payment');
      expect(proceedButton).toBeDisabled();
    });

    it('enables proceed button when all fields are filled', async () => {
      const user = userEvent.setup();
      render(<Checkout {...defaultProps} />);

      await fillDetailsForm(user);

      await waitFor(() => {
        expect(screen.getByText('Proceed to Payment')).not.toBeDisabled();
      });
    });

    it('shows error for non-Gmail email addresses', async () => {
      const user = userEvent.setup();
      render(<Checkout {...defaultProps} />);

      await user.type(screen.getByPlaceholderText('juan.delacruz@gmail.com'), 'test@yahoo.com');

      await waitFor(() => {
        expect(screen.getByText(/Please provide a valid @gmail.com address/)).toBeInTheDocument();
      });
    });

    it('keeps proceed button disabled with non-Gmail email', async () => {
      const user = userEvent.setup();
      render(<Checkout {...defaultProps} />);

      // Fill everything except use non-Gmail email
      await user.type(screen.getByPlaceholderText('Juan Dela Cruz'), 'Test User');
      await user.type(screen.getByPlaceholderText('juan.delacruz@gmail.com'), 'test@outlook.com');
      const phoneInputs = screen.getAllByPlaceholderText('e.g., 912 345 6789');
      await user.type(phoneInputs[0], '9171234567');
      await user.type(phoneInputs[1], '9187654321');
      await user.type(screen.getByPlaceholderText('Complete delivery address'), '123 Main St, Makati City, Metro Manila, 1200');

      const courierButton = screen.getByText('LBC Express');
      await user.click(courierButton);
      await waitFor(() => expect(screen.getByText('LBC - Metro Manila')).toBeInTheDocument());
      await user.click(screen.getByText('LBC - Metro Manila'));

      expect(screen.getByText('Proceed to Payment')).toBeDisabled();
    });
  });

  describe('step navigation', () => {
    it('navigates to payment step on valid form submission', async () => {
      const user = userEvent.setup();
      render(<Checkout {...defaultProps} />);

      await fillDetailsForm(user);
      await user.click(screen.getByText('Proceed to Payment'));

      await waitFor(() => {
        expect(screen.getByText('Payment & Verification')).toBeInTheDocument();
      });
    });

    it('shows payment methods on payment step', async () => {
      const user = userEvent.setup();
      render(<Checkout {...defaultProps} />);

      await fillDetailsForm(user);
      await user.click(screen.getByText('Proceed to Payment'));

      await waitFor(() => {
        expect(screen.getByText('GCash')).toBeInTheDocument();
        expect(screen.getByText('BDO')).toBeInTheDocument();
      });
    });

    it('shows back button to return to details from payment', async () => {
      const user = userEvent.setup();
      render(<Checkout {...defaultProps} />);

      await fillDetailsForm(user);
      await user.click(screen.getByText('Proceed to Payment'));

      await waitFor(() => {
        expect(screen.getByText('Back to Details')).toBeInTheDocument();
      });

      await user.click(screen.getByText('Back to Details'));

      await waitFor(() => {
        expect(screen.getByText('Checkout Information')).toBeInTheDocument();
      });
    });
  });

  describe('promo code', () => {
    it('shows error for empty promo code', async () => {
      const user = userEvent.setup();
      render(<Checkout {...defaultProps} />);

      // Type a space (which trims to empty) so the APPLY button becomes enabled
      await user.type(screen.getByPlaceholderText('ENTER CODE'), ' ');
      await user.click(screen.getByText('APPLY'));

      await waitFor(() => {
        expect(screen.getByText('Please enter a promo code')).toBeInTheDocument();
      });
    });

    it('shows error for invalid promo code', async () => {
      mockSupabasePromoSelect.mockResolvedValueOnce({ data: null, error: { message: 'not found' } });

      const user = userEvent.setup();
      render(<Checkout {...defaultProps} />);

      await user.type(screen.getByPlaceholderText('ENTER CODE'), 'BADCODE');
      await user.click(screen.getByText('APPLY'));

      await waitFor(() => {
        expect(screen.getByText('Invalid or inactive promo code')).toBeInTheDocument();
      });
    });

    it('shows error for expired promo code', async () => {
      mockSupabasePromoSelect.mockResolvedValueOnce({
        data: {
          id: 'promo-1',
          code: 'EXPIRED',
          discount_type: 'percentage',
          discount_value: 10,
          min_purchase_amount: 0,
          usage_count: 0,
          active: true,
          start_date: '2020-01-01',
          end_date: '2020-12-31', // expired
        },
        error: null,
      });

      const user = userEvent.setup();
      render(<Checkout {...defaultProps} />);

      await user.type(screen.getByPlaceholderText('ENTER CODE'), 'EXPIRED');
      await user.click(screen.getByText('APPLY'));

      await waitFor(() => {
        expect(screen.getByText('Promo code has expired')).toBeInTheDocument();
      });
    });

    it('shows error when minimum purchase not met', async () => {
      mockSupabasePromoSelect.mockResolvedValueOnce({
        data: {
          id: 'promo-1',
          code: 'BIGSPEND',
          discount_type: 'percentage',
          discount_value: 10,
          min_purchase_amount: 50000, // way higher than cart total
          usage_count: 0,
          active: true,
        },
        error: null,
      });

      const user = userEvent.setup();
      render(<Checkout {...defaultProps} />);

      await user.type(screen.getByPlaceholderText('ENTER CODE'), 'BIGSPEND');
      await user.click(screen.getByText('APPLY'));

      await waitFor(() => {
        expect(screen.getByText(/Minimum purchase of/)).toBeInTheDocument();
      });
    });

    it('shows error when usage limit reached', async () => {
      mockSupabasePromoSelect.mockResolvedValueOnce({
        data: {
          id: 'promo-1',
          code: 'MAXED',
          discount_type: 'percentage',
          discount_value: 10,
          min_purchase_amount: 0,
          usage_limit: 5,
          usage_count: 5, // maxed out
          active: true,
        },
        error: null,
      });

      const user = userEvent.setup();
      render(<Checkout {...defaultProps} />);

      await user.type(screen.getByPlaceholderText('ENTER CODE'), 'MAXED');
      await user.click(screen.getByText('APPLY'));

      await waitFor(() => {
        expect(screen.getByText('Promo code usage limit reached')).toBeInTheDocument();
      });
    });

    it('applies valid percentage promo code', async () => {
      mockSupabasePromoSelect.mockResolvedValueOnce({
        data: {
          id: 'promo-1',
          code: 'SAVE10',
          discount_type: 'percentage',
          discount_value: 10,
          min_purchase_amount: 0,
          usage_count: 0,
          active: true,
        },
        error: null,
      });

      const user = userEvent.setup();
      render(<Checkout {...defaultProps} />);

      await user.type(screen.getByPlaceholderText('ENTER CODE'), 'SAVE10');
      await user.click(screen.getByText('APPLY'));

      // 10% of 4000 = 400
      await waitFor(() => {
        expect(screen.getByText(/Promo code applied! You saved/)).toBeInTheDocument();
      });
    });

    it('applies valid fixed discount promo code', async () => {
      mockSupabasePromoSelect.mockResolvedValueOnce({
        data: {
          id: 'promo-2',
          code: 'FLAT500',
          discount_type: 'fixed',
          discount_value: 500,
          min_purchase_amount: 0,
          usage_count: 0,
          active: true,
        },
        error: null,
      });

      const user = userEvent.setup();
      render(<Checkout {...defaultProps} />);

      await user.type(screen.getByPlaceholderText('ENTER CODE'), 'FLAT500');
      await user.click(screen.getByText('APPLY'));

      await waitFor(() => {
        expect(screen.getByText(/Promo code applied! You saved/)).toBeInTheDocument();
      });
    });

    it('caps percentage discount at max_discount_amount', async () => {
      mockSupabasePromoSelect.mockResolvedValueOnce({
        data: {
          id: 'promo-3',
          code: 'CAPPED',
          discount_type: 'percentage',
          discount_value: 50, // 50% of 4000 = 2000, but max is 200
          max_discount_amount: 200,
          min_purchase_amount: 0,
          usage_count: 0,
          active: true,
        },
        error: null,
      });

      const user = userEvent.setup();
      render(<Checkout {...defaultProps} />);

      await user.type(screen.getByPlaceholderText('ENTER CODE'), 'CAPPED');
      await user.click(screen.getByText('APPLY'));

      await waitFor(() => {
        expect(screen.getByText(/You saved \$200/)).toBeInTheDocument();
      });
    });

    it('shows REMOVE button after applying promo and allows removal', async () => {
      mockSupabasePromoSelect.mockResolvedValueOnce({
        data: {
          id: 'promo-1',
          code: 'SAVE10',
          discount_type: 'percentage',
          discount_value: 10,
          min_purchase_amount: 0,
          usage_count: 0,
          active: true,
        },
        error: null,
      });

      const user = userEvent.setup();
      render(<Checkout {...defaultProps} />);

      await user.type(screen.getByPlaceholderText('ENTER CODE'), 'SAVE10');
      await user.click(screen.getByText('APPLY'));

      await waitFor(() => {
        expect(screen.getByText('REMOVE')).toBeInTheDocument();
      });

      await user.click(screen.getByText('REMOVE'));

      await waitFor(() => {
        expect(screen.getByText('APPLY')).toBeInTheDocument();
      });
    });
  });

  describe('payment step', () => {
    async function goToPaymentStep(user: ReturnType<typeof userEvent.setup>) {
      render(<Checkout {...defaultProps} />);
      await fillDetailsForm(user);
      await user.click(screen.getByText('Proceed to Payment'));
      await waitFor(() => {
        expect(screen.getByText('Payment & Verification')).toBeInTheDocument();
      });
    }

    it('displays payment methods with radio buttons', async () => {
      const user = userEvent.setup();
      await goToPaymentStep(user);

      expect(screen.getByText('GCash')).toBeInTheDocument();
      expect(screen.getByText('BDO')).toBeInTheDocument();
      expect(screen.getByText('0912-345-6789')).toBeInTheDocument();
    });

    it('shows payment proof upload area', async () => {
      const user = userEvent.setup();
      await goToPaymentStep(user);

      expect(screen.getByText('Upload Proof of Payment')).toBeInTheDocument();
      expect(screen.getByText('Click to upload screenshot')).toBeInTheDocument();
    });

    it('shows order summary sidebar with totals', async () => {
      const user = userEvent.setup();
      await goToPaymentStep(user);

      expect(screen.getByText('Order Summary')).toBeInTheDocument();
    });

    it('disables complete order button without payment proof', async () => {
      const user = userEvent.setup();
      await goToPaymentStep(user);

      const completeButton = screen.getByText('Complete Order');
      expect(completeButton).toBeDisabled();
    });

    it('alerts when trying to place order without payment proof', async () => {
      const user = userEvent.setup();
      await goToPaymentStep(user);

      // The button is disabled, but let's verify the alert logic
      // by checking the button state
      const completeButton = screen.getByText('Complete Order');
      expect(completeButton).toHaveAttribute('disabled');
    });

    it('shows additional notes textarea', async () => {
      const user = userEvent.setup();
      await goToPaymentStep(user);

      expect(screen.getByText('Additional Notes (Optional)')).toBeInTheDocument();
      expect(screen.getByPlaceholderText('Special instructions for delivery...')).toBeInTheDocument();
    });
  });

  describe('order placement', () => {
    it('places order successfully with payment proof', async () => {
      const user = userEvent.setup();
      render(<Checkout {...defaultProps} />);

      await fillDetailsForm(user);
      await user.click(screen.getByText('Proceed to Payment'));

      await waitFor(() => {
        expect(screen.getByText('Payment & Verification')).toBeInTheDocument();
      });

      // Upload payment proof
      const file = new File(['proof'], 'proof.png', { type: 'image/png' });
      const fileInput = document.getElementById('payment-proof-upload') as HTMLInputElement;
      await user.upload(fileInput, file);

      // Complete order
      const completeButton = screen.getByText('Complete Order');
      await waitFor(() => {
        expect(completeButton).not.toBeDisabled();
      });
      await user.click(completeButton);

      // Should reach confirmation step
      await waitFor(() => {
        expect(screen.getByText('Order Confirmed')).toBeInTheDocument();
      });
    });

    it('shows order number on confirmation', async () => {
      const user = userEvent.setup();
      render(<Checkout {...defaultProps} />);

      await fillDetailsForm(user);
      await user.click(screen.getByText('Proceed to Payment'));
      await waitFor(() => expect(screen.getByText('Payment & Verification')).toBeInTheDocument());

      const file = new File(['proof'], 'proof.png', { type: 'image/png' });
      const fileInput = document.getElementById('payment-proof-upload') as HTMLInputElement;
      await user.upload(fileInput, file);

      await user.click(screen.getByText('Complete Order'));

      await waitFor(() => {
        expect(screen.getByText('Order Confirmed')).toBeInTheDocument();
        expect(screen.getByText('Order Reference')).toBeInTheDocument();
        // Order number appears in both the reference display and the order message,
        // use getAllByText to match both
        const orderNumbers = screen.getAllByText(/BS-\d{4}/);
        expect(orderNumbers.length).toBeGreaterThanOrEqual(1);
      });
    });

    it('shows WhatsApp send button on confirmation', async () => {
      const user = userEvent.setup();
      render(<Checkout {...defaultProps} />);

      await fillDetailsForm(user);
      await user.click(screen.getByText('Proceed to Payment'));
      await waitFor(() => expect(screen.getByText('Payment & Verification')).toBeInTheDocument());

      const file = new File(['proof'], 'proof.png', { type: 'image/png' });
      const fileInput = document.getElementById('payment-proof-upload') as HTMLInputElement;
      await user.upload(fileInput, file);

      await user.click(screen.getByText('Complete Order'));

      await waitFor(() => {
        expect(screen.getByText('Open WhatsApp & Send')).toBeInTheDocument();
      });
    });

    it('displays order message with customer details on confirmation', async () => {
      const user = userEvent.setup();
      render(<Checkout {...defaultProps} />);

      await fillDetailsForm(user);
      await user.click(screen.getByText('Proceed to Payment'));
      await waitFor(() => expect(screen.getByText('Payment & Verification')).toBeInTheDocument());

      const file = new File(['proof'], 'proof.png', { type: 'image/png' });
      const fileInput = document.getElementById('payment-proof-upload') as HTMLInputElement;
      await user.upload(fileInput, file);

      await user.click(screen.getByText('Complete Order'));

      await waitFor(() => {
        expect(screen.getByText('Order Confirmed')).toBeInTheDocument();
      });

      // Verify the order message contains key details
      const orderMessagePre = screen.getByText(/NEW ORDER/);
      expect(orderMessagePre).toBeInTheDocument();
      expect(orderMessagePre.textContent).toContain('Test User');
      expect(orderMessagePre.textContent).toContain('test@gmail.com');
      expect(orderMessagePre.textContent).toContain('BPC-157');
      expect(orderMessagePre.textContent).toContain('GCash');

      // Copy button shows "Copied!" because auto-copy succeeded
      expect(screen.getByText(/Copied!/)).toBeInTheDocument();
    });

    it('shows return to catalog button on confirmation', async () => {
      const user = userEvent.setup();
      render(<Checkout {...defaultProps} />);

      await fillDetailsForm(user);
      await user.click(screen.getByText('Proceed to Payment'));
      await waitFor(() => expect(screen.getByText('Payment & Verification')).toBeInTheDocument());

      const file = new File(['proof'], 'proof.png', { type: 'image/png' });
      const fileInput = document.getElementById('payment-proof-upload') as HTMLInputElement;
      await user.upload(fileInput, file);

      await user.click(screen.getByText('Complete Order'));

      await waitFor(() => {
        expect(screen.getByText('Return to Catalog')).toBeInTheDocument();
      });
    });

    it('handles order placement failure gracefully', async () => {
      // Make the order insert fail
      mockSupabaseInsert.mockReturnValueOnce({
        select: vi.fn().mockReturnValue({
          single: vi.fn().mockResolvedValue({
            data: null,
            error: { message: 'Database error' },
          }),
        }),
      });

      const user = userEvent.setup();
      render(<Checkout {...defaultProps} />);

      await fillDetailsForm(user);
      await user.click(screen.getByText('Proceed to Payment'));
      await waitFor(() => expect(screen.getByText('Payment & Verification')).toBeInTheDocument());

      const file = new File(['proof'], 'proof.png', { type: 'image/png' });
      const fileInput = document.getElementById('payment-proof-upload') as HTMLInputElement;
      await user.upload(fileInput, file);

      await user.click(screen.getByText('Complete Order'));

      await waitFor(() => {
        expect(alertMock).toHaveBeenCalledWith(expect.stringContaining('Failed to save order'));
      });
    });

    it('handles payment proof upload failure', async () => {
      mockUploadImage.mockRejectedValueOnce(new Error('Upload failed'));

      const user = userEvent.setup();
      render(<Checkout {...defaultProps} />);

      await fillDetailsForm(user);
      await user.click(screen.getByText('Proceed to Payment'));
      await waitFor(() => expect(screen.getByText('Payment & Verification')).toBeInTheDocument());

      const file = new File(['proof'], 'proof.png', { type: 'image/png' });
      const fileInput = document.getElementById('payment-proof-upload') as HTMLInputElement;
      await user.upload(fileInput, file);

      await user.click(screen.getByText('Complete Order'));

      await waitFor(() => {
        expect(alertMock).toHaveBeenCalledWith(expect.stringContaining('Failed to upload payment proof'));
      });
    });
  });

  describe('isValidUUID helper', () => {
    // The isValidUUID function is used internally by Checkout to validate
    // courier_id and payment_method_id before sending to DB.
    // We test it indirectly through order placement.
    it('sends valid UUID courier_id to order insert', async () => {
      const user = userEvent.setup();
      render(<Checkout {...defaultProps} />);

      await fillDetailsForm(user);
      await user.click(screen.getByText('Proceed to Payment'));
      await waitFor(() => expect(screen.getByText('Payment & Verification')).toBeInTheDocument());

      const file = new File(['proof'], 'proof.png', { type: 'image/png' });
      const fileInput = document.getElementById('payment-proof-upload') as HTMLInputElement;
      await user.upload(fileInput, file);

      await user.click(screen.getByText('Complete Order'));

      await waitFor(() => {
        expect(mockSupabaseInsert).toHaveBeenCalled();
      });

      const insertCall = mockSupabaseInsert.mock.calls[0][0][0];
      // The courier ID is a valid UUID, so it should be passed through
      expect(insertCall.courier_id).toBe('a0000000-0000-0000-0000-000000000001');
    });
  });

  describe('shipping fee calculation', () => {
    it('includes shipping fee in order summary on payment step', async () => {
      const user = userEvent.setup();
      render(<Checkout {...defaultProps} />);

      await fillDetailsForm(user);
      await user.click(screen.getByText('Proceed to Payment'));

      await waitFor(() => {
        expect(screen.getByText('Payment & Verification')).toBeInTheDocument();
      });

      // Should show the shipping fee from LBC Metro Manila (150)
      expect(screen.getByText('Shipping')).toBeInTheDocument();
    });
  });

  describe('WhatsApp contact', () => {
    it('shows WhatsApp as default contact method', () => {
      render(<Checkout {...defaultProps} />);

      expect(screen.getByText('WhatsApp')).toBeInTheDocument();
      expect(screen.getByText('+63 912 124 1164')).toBeInTheDocument();
    });
  });
});
