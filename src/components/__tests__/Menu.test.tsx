import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import Menu from '../Menu';
import { mockProduct, mockProductNoDiscount, mockProductOutOfStock } from '../../test/fixtures';
import type { Product } from '../../types';

// Mock child components
vi.mock('../MenuItemCard', () => ({
  default: ({ product, cartQuantity, onProductClick }: any) => (
    <div data-testid={`menu-item-${product.id}`} onClick={() => onProductClick(product)}>
      <span>{product.name}</span>
      <span data-testid={`cart-qty-${product.id}`}>{cartQuantity}</span>
    </div>
  ),
}));

vi.mock('../Hero', () => ({
  default: ({ onShopAll }: any) => (
    <div data-testid="hero">
      <button onClick={onShopAll}>Shop All</button>
    </div>
  ),
}));

vi.mock('../ProductDetailModal', () => ({
  default: ({ product, onClose }: any) => (
    <div data-testid="product-modal">
      <span>{product.name} Modal</span>
      <button onClick={onClose}>Close</button>
    </div>
  ),
}));

// Mock lucide-react
vi.mock('lucide-react', () => ({
  Search: () => <span data-testid="search-icon">Search</span>,
  Filter: () => <span data-testid="filter-icon">Filter</span>,
  Package: () => <span data-testid="package-icon">Package</span>,
}));

describe('Menu component', () => {
  const products: Product[] = [mockProduct, mockProductNoDiscount, mockProductOutOfStock];

  const defaultProps = {
    menuItems: products,
    addToCart: vi.fn(),
    cartItems: [],
    updateQuantity: vi.fn(),
  };

  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('rendering', () => {
    it('renders Hero component', () => {
      render(<Menu {...defaultProps} />);
      expect(screen.getByTestId('hero')).toBeInTheDocument();
    });

    it('renders search input', () => {
      render(<Menu {...defaultProps} />);
      expect(screen.getByPlaceholderText('Search by name or product code...')).toBeInTheDocument();
    });

    it('renders sort dropdown', () => {
      render(<Menu {...defaultProps} />);
      expect(screen.getByText('Sort by Name')).toBeInTheDocument();
    });

    it('renders product catalog heading', () => {
      render(<Menu {...defaultProps} />);
      expect(screen.getByText('Product Catalog')).toBeInTheDocument();
    });

    it('renders results count', () => {
      render(<Menu {...defaultProps} />);
      expect(screen.getByText('3 Results')).toBeInTheDocument();
    });

    it('renders all product cards', () => {
      render(<Menu {...defaultProps} />);
      expect(screen.getByTestId('menu-item-prod-1')).toBeInTheDocument();
      expect(screen.getByTestId('menu-item-prod-2')).toBeInTheDocument();
      expect(screen.getByTestId('menu-item-prod-3')).toBeInTheDocument();
    });
  });

  describe('search filtering', () => {
    it('filters products by name', () => {
      render(<Menu {...defaultProps} />);
      const searchInput = screen.getByPlaceholderText('Search by name or product code...');
      fireEvent.change(searchInput, { target: { value: 'TB-500' } });

      expect(screen.getByTestId('menu-item-prod-2')).toBeInTheDocument();
      expect(screen.queryByTestId('menu-item-prod-1')).not.toBeInTheDocument();
      expect(screen.queryByTestId('menu-item-prod-3')).not.toBeInTheDocument();
      expect(screen.getByText('1 Results')).toBeInTheDocument();
    });

    it('filters products by code', () => {
      render(<Menu {...defaultProps} />);
      const searchInput = screen.getByPlaceholderText('Search by name or product code...');
      // All mock products inherit code 'BPC157' from mockProduct, so this matches all 3
      fireEvent.change(searchInput, { target: { value: 'BPC157' } });

      expect(screen.getByTestId('menu-item-prod-1')).toBeInTheDocument();
      expect(screen.getByTestId('menu-item-prod-2')).toBeInTheDocument();
    });

    it('is case-insensitive', () => {
      render(<Menu {...defaultProps} />);
      const searchInput = screen.getByPlaceholderText('Search by name or product code...');
      fireEvent.change(searchInput, { target: { value: 'tb-500' } });

      expect(screen.getByTestId('menu-item-prod-2')).toBeInTheDocument();
    });

    it('shows no products found when search has no matches', () => {
      render(<Menu {...defaultProps} />);
      const searchInput = screen.getByPlaceholderText('Search by name or product code...');
      fireEvent.change(searchInput, { target: { value: 'xyz-nonexistent' } });

      expect(screen.getByText('No products found')).toBeInTheDocument();
      expect(screen.getByText('No products match "xyz-nonexistent".')).toBeInTheDocument();
    });

    it('shows Clear Search button when no results', () => {
      render(<Menu {...defaultProps} />);
      const searchInput = screen.getByPlaceholderText('Search by name or product code...');
      fireEvent.change(searchInput, { target: { value: 'xyz' } });

      const clearButton = screen.getByText('Clear Search');
      expect(clearButton).toBeInTheDocument();

      fireEvent.click(clearButton);
      expect(screen.getByText('3 Results')).toBeInTheDocument();
    });
  });

  describe('sorting', () => {
    it('sorts by name by default', () => {
      render(<Menu {...defaultProps} />);
      const items = screen.getAllByText(/BPC-157|TB-500|GHK-Cu/);
      expect(items.length).toBe(3);
    });

    it('allows changing sort to price', () => {
      render(<Menu {...defaultProps} />);
      const select = screen.getByDisplayValue('Sort by Name');
      fireEvent.change(select, { target: { value: 'price' } });
      expect(screen.getByDisplayValue('Sort by Price')).toBeInTheDocument();
    });

    it('allows changing sort to purity', () => {
      render(<Menu {...defaultProps} />);
      const select = screen.getByDisplayValue('Sort by Name');
      fireEvent.change(select, { target: { value: 'purity' } });
      expect(screen.getByDisplayValue('Sort by Purity')).toBeInTheDocument();
    });
  });

  describe('empty state', () => {
    it('shows empty state when no products provided', () => {
      render(<Menu {...defaultProps} menuItems={[]} />);
      expect(screen.getByText('No products found')).toBeInTheDocument();
      expect(screen.getByText('No products available.')).toBeInTheDocument();
    });
  });

  describe('product detail modal', () => {
    it('opens modal when product card is clicked', () => {
      render(<Menu {...defaultProps} />);
      fireEvent.click(screen.getByTestId('menu-item-prod-1'));
      expect(screen.getByTestId('product-modal')).toBeInTheDocument();
      expect(screen.getByText('BPC-157 Modal')).toBeInTheDocument();
    });

    it('closes modal when close button is clicked', () => {
      render(<Menu {...defaultProps} />);
      fireEvent.click(screen.getByTestId('menu-item-prod-1'));
      expect(screen.getByTestId('product-modal')).toBeInTheDocument();

      fireEvent.click(screen.getByText('Close'));
      expect(screen.queryByTestId('product-modal')).not.toBeInTheDocument();
    });
  });

  describe('cart quantity tracking', () => {
    it('passes cart quantity to MenuItemCard', () => {
      const cartItems = [
        { product: mockProduct, quantity: 3, price: 70, currency: 'USD' as const },
      ];

      render(<Menu {...defaultProps} cartItems={cartItems} />);
      expect(screen.getByTestId('cart-qty-prod-1')).toHaveTextContent('3');
      expect(screen.getByTestId('cart-qty-prod-2')).toHaveTextContent('0');
    });
  });
});
