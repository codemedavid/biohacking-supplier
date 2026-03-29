import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import Cart from '../Cart';
import { mockProduct, mockProductNoDiscount, mockVariation, mockCartItem } from '../../test/fixtures';
import type { CartItem } from '../../types';

// Mock lucide-react icons
vi.mock('lucide-react', () => ({
  Trash2: () => <span data-testid="trash-icon">Trash</span>,
  ShoppingBag: () => <span data-testid="shopping-bag-icon">Bag</span>,
  ArrowLeft: () => <span data-testid="arrow-left-icon">Back</span>,
  CreditCard: () => <span data-testid="credit-card-icon">Card</span>,
  Plus: () => <span data-testid="plus-icon">+</span>,
  Minus: () => <span data-testid="minus-icon">-</span>,
  Sparkles: () => <span data-testid="sparkles-icon">Sparkles</span>,
  Activity: () => <span data-testid="activity-icon">Activity</span>,
  Box: () => <span data-testid="box-icon">Box</span>,
}));

describe('Cart component', () => {
  const defaultProps = {
    cartItems: [] as CartItem[],
    updateQuantity: vi.fn(),
    removeFromCart: vi.fn(),
    clearCart: vi.fn(),
    getTotalPrice: vi.fn(() => 0),
    onContinueShopping: vi.fn(),
    onCheckout: vi.fn(),
  };

  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('empty cart', () => {
    it('renders empty state message', () => {
      render(<Cart {...defaultProps} />);
      expect(screen.getByText('Your cart is empty')).toBeInTheDocument();
    });

    it('renders Browse Catalog button', () => {
      render(<Cart {...defaultProps} />);
      expect(screen.getByText('Browse Catalog')).toBeInTheDocument();
    });

    it('calls onContinueShopping when Browse Catalog is clicked', () => {
      render(<Cart {...defaultProps} />);
      fireEvent.click(screen.getByText('Browse Catalog'));
      expect(defaultProps.onContinueShopping).toHaveBeenCalledTimes(1);
    });
  });

  describe('cart with items', () => {
    const cartItems: CartItem[] = [
      { ...mockCartItem },
      {
        product: mockProductNoDiscount,
        quantity: 1,
        price: 84.23,
        currency: 'USD',
      },
    ];

    const propsWithItems = {
      ...defaultProps,
      cartItems,
      getTotalPrice: vi.fn(() => 224.23),
    };

    it('renders product names', () => {
      render(<Cart {...propsWithItems} />);
      expect(screen.getByText('BPC-157')).toBeInTheDocument();
      expect(screen.getByText('TB-500')).toBeInTheDocument();
    });

    it('renders item count', () => {
      render(<Cart {...propsWithItems} />);
      expect(screen.getByText('3 Items')).toBeInTheDocument();
    });

    it('renders Shopping Cart heading', () => {
      render(<Cart {...propsWithItems} />);
      expect(screen.getByText('Shopping Cart')).toBeInTheDocument();
    });

    it('renders quantity for each item', () => {
      render(<Cart {...propsWithItems} />);
      expect(screen.getByText('2')).toBeInTheDocument(); // mockCartItem quantity
      expect(screen.getByText('1')).toBeInTheDocument(); // second item quantity
    });

    it('calls removeFromCart when trash button is clicked', () => {
      render(<Cart {...propsWithItems} />);
      const removeButtons = screen.getAllByTitle('Remove item');
      fireEvent.click(removeButtons[0]);
      expect(defaultProps.removeFromCart).toHaveBeenCalledWith(0);
    });

    it('calls clearCart when Clear Cart is clicked', () => {
      render(<Cart {...propsWithItems} />);
      fireEvent.click(screen.getByText('Clear Cart'));
      expect(defaultProps.clearCart).toHaveBeenCalledTimes(1);
    });

    it('calls onCheckout when Proceed to Checkout is clicked', () => {
      render(<Cart {...propsWithItems} />);
      fireEvent.click(screen.getByText('Proceed to Checkout'));
      expect(defaultProps.onCheckout).toHaveBeenCalledTimes(1);
    });

    it('renders Back to Catalog button', () => {
      render(<Cart {...propsWithItems} />);
      expect(screen.getByText('Back to Catalog')).toBeInTheDocument();
    });

    it('calls onContinueShopping when Continue Browsing is clicked', () => {
      render(<Cart {...propsWithItems} />);
      fireEvent.click(screen.getByText('Continue Browsing'));
      expect(defaultProps.onContinueShopping).toHaveBeenCalledTimes(1);
    });

    it('renders trust badges', () => {
      render(<Cart {...propsWithItems} />);
      expect(screen.getByText('Secure Encrypted Checkout')).toBeInTheDocument();
      expect(screen.getByText('HPLC Verified Purity')).toBeInTheDocument();
      expect(screen.getByText('Discreet Packaging')).toBeInTheDocument();
    });

    it('renders Order Summary section', () => {
      render(<Cart {...propsWithItems} />);
      expect(screen.getByText('Order Summary')).toBeInTheDocument();
      expect(screen.getByText('Subtotal')).toBeInTheDocument();
    });
  });

  describe('cart item with variation', () => {
    it('displays variation name', () => {
      const cartItems: CartItem[] = [
        {
          product: mockProduct,
          variation: mockVariation,
          quantity: 1,
          price: 84.23,
          currency: 'USD',
        },
      ];

      render(
        <Cart
          {...defaultProps}
          cartItems={cartItems}
          getTotalPrice={() => 84.23}
        />
      );
      expect(screen.getByText('Format: 5mg')).toBeInTheDocument();
    });
  });

  describe('cart item with pen type', () => {
    it('displays disposable pen badge', () => {
      const cartItems: CartItem[] = [
        {
          product: mockProduct,
          variation: mockVariation,
          quantity: 1,
          price: 95,
          penType: 'disposable',
          currency: 'USD',
        },
      ];

      render(
        <Cart
          {...defaultProps}
          cartItems={cartItems}
          getTotalPrice={() => 95}
        />
      );
      expect(screen.getByText('Disposable Pen')).toBeInTheDocument();
    });

    it('displays reusable pen badge', () => {
      const cartItems: CartItem[] = [
        {
          product: mockProduct,
          variation: mockVariation,
          quantity: 1,
          price: 90,
          penType: 'reusable',
          currency: 'USD',
        },
      ];

      render(
        <Cart
          {...defaultProps}
          cartItems={cartItems}
          getTotalPrice={() => 90}
        />
      );
      expect(screen.getByText('Reusable Pen')).toBeInTheDocument();
    });
  });

  describe('cart item with purchase mode', () => {
    it('displays purchase mode badge', () => {
      const cartItems: CartItem[] = [
        {
          product: mockProduct,
          quantity: 1,
          price: 84.23,
          purchaseMode: 'box',
          fulfillmentType: 'preorder',
          currency: 'USD',
        },
      ];

      render(
        <Cart
          {...defaultProps}
          cartItems={cartItems}
          getTotalPrice={() => 84.23}
        />
      );
      expect(screen.getByText('Per Box')).toBeInTheDocument();
    });
  });

  describe('quantity controls', () => {
    it('calls updateQuantity with decremented value on minus click', () => {
      const cartItems: CartItem[] = [
        { ...mockCartItem, quantity: 3 },
      ];

      render(
        <Cart
          {...defaultProps}
          cartItems={cartItems}
          getTotalPrice={() => 210}
        />
      );

      // Click the minus button (first button in quantity controls)
      const minusButtons = screen.getAllByTestId('minus-icon');
      fireEvent.click(minusButtons[0].closest('button')!);
      expect(defaultProps.updateQuantity).toHaveBeenCalledWith(0, 2);
    });
  });

  describe('product code display', () => {
    it('shows product code when available', () => {
      const cartItems: CartItem[] = [{ ...mockCartItem }];

      render(
        <Cart
          {...defaultProps}
          cartItems={cartItems}
          getTotalPrice={() => 140}
        />
      );
      expect(screen.getByText('BPC157')).toBeInTheDocument();
    });
  });

  describe('purity display', () => {
    it('shows purity percentage when available', () => {
      const cartItems: CartItem[] = [{ ...mockCartItem }];

      render(
        <Cart
          {...defaultProps}
          cartItems={cartItems}
          getTotalPrice={() => 140}
        />
      );
      expect(screen.getByText('99.5% Purity')).toBeInTheDocument();
    });
  });
});
