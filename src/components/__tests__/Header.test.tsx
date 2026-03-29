import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import Header from '../Header';

// Mock lucide-react icons
vi.mock('lucide-react', () => ({
  ShoppingCart: () => <span data-testid="cart-icon">Cart</span>,
  Menu: () => <span data-testid="menu-icon">Menu</span>,
  X: () => <span data-testid="close-icon">X</span>,
  FlaskConical: () => <span data-testid="flask-icon">Flask</span>,
  HelpCircle: () => <span data-testid="help-icon">Help</span>,
  Truck: () => <span data-testid="truck-icon">Truck</span>,
  Calculator: () => <span data-testid="calc-icon">Calc</span>,
}));

describe('Header component', () => {
  const defaultProps = {
    cartItemsCount: 0,
    onCartClick: vi.fn(),
    onMenuClick: vi.fn(),
  };

  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('rendering', () => {
    it('renders the brand name', () => {
      render(<Header {...defaultProps} />);
      expect(screen.getAllByText('Biohacking Supplier').length).toBeGreaterThan(0);
    });

    it('renders desktop navigation links', () => {
      render(<Header {...defaultProps} />);
      expect(screen.getByText('Products')).toBeInTheDocument();
      expect(screen.getByText('Calculator')).toBeInTheDocument();
      expect(screen.getByText('Protocols')).toBeInTheDocument();
      expect(screen.getByText('FAQ')).toBeInTheDocument();
    });

    it('renders cart icon', () => {
      render(<Header {...defaultProps} />);
      expect(screen.getAllByTestId('cart-icon').length).toBeGreaterThan(0);
    });

    it('renders mobile menu toggle button', () => {
      render(<Header {...defaultProps} />);
      expect(screen.getByLabelText('Toggle menu')).toBeInTheDocument();
    });
  });

  describe('cart badge', () => {
    it('does not show badge when cart is empty', () => {
      render(<Header {...defaultProps} cartItemsCount={0} />);
      expect(screen.queryByText('0')).not.toBeInTheDocument();
    });

    it('shows badge with count when cart has items', () => {
      render(<Header {...defaultProps} cartItemsCount={5} />);
      expect(screen.getByText('5')).toBeInTheDocument();
    });

    it('shows 99+ when cart has more than 99 items', () => {
      render(<Header {...defaultProps} cartItemsCount={150} />);
      expect(screen.getByText('99+')).toBeInTheDocument();
    });
  });

  describe('interactions', () => {
    it('calls onCartClick when cart button is clicked', () => {
      render(<Header {...defaultProps} />);
      const cartButtons = screen.getAllByTestId('cart-icon');
      fireEvent.click(cartButtons[0].closest('button')!);
      expect(defaultProps.onCartClick).toHaveBeenCalledTimes(1);
    });

    it('calls onMenuClick when logo/brand is clicked', () => {
      render(<Header {...defaultProps} />);
      const brandButtons = screen.getAllByText('Biohacking Supplier');
      fireEvent.click(brandButtons[0].closest('button')!);
      expect(defaultProps.onMenuClick).toHaveBeenCalled();
    });

    it('calls onMenuClick when Products nav button is clicked', () => {
      render(<Header {...defaultProps} />);
      fireEvent.click(screen.getByText('Products'));
      expect(defaultProps.onMenuClick).toHaveBeenCalled();
    });
  });

  describe('mobile menu', () => {
    it('opens mobile menu drawer on toggle click', () => {
      render(<Header {...defaultProps} />);
      fireEvent.click(screen.getByLabelText('Toggle menu'));
      // The mobile drawer should now be visible with navigation items
      // Mobile menu has its own Products, Calculator, Protocols, Track Order, FAQ
      expect(screen.getByText('Track Order')).toBeInTheDocument();
    });

    it('closes mobile menu when close button is clicked', () => {
      render(<Header {...defaultProps} />);
      // Open menu
      fireEvent.click(screen.getByLabelText('Toggle menu'));
      expect(screen.getByText('Track Order')).toBeInTheDocument();

      // Close it via the X button inside the drawer
      const closeButtons = screen.getAllByTestId('close-icon');
      // The close button inside the drawer
      fireEvent.click(closeButtons[closeButtons.length - 1].closest('button')!);
      expect(screen.queryByText('Track Order')).not.toBeInTheDocument();
    });

    it('closes mobile menu and calls onMenuClick when Products is clicked in drawer', () => {
      render(<Header {...defaultProps} />);
      fireEvent.click(screen.getByLabelText('Toggle menu'));

      // Click Products in the mobile drawer
      const productButtons = screen.getAllByText('Products');
      // The mobile one is the last one
      fireEvent.click(productButtons[productButtons.length - 1]);
      expect(defaultProps.onMenuClick).toHaveBeenCalled();
    });
  });
});
