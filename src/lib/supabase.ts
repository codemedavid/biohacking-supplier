import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export type Database = {
  public: {
    Tables: {
      categories: {
        Row: {
          id: string;
          name: string;
          icon: string;
          sort_order: number;
          active: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id: string;
          name: string;
          icon: string;
          sort_order?: number;
          active?: boolean;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          name?: string;
          icon?: string;
          sort_order?: number;
          active?: boolean;
          created_at?: string;
          updated_at?: string;
        };
      };
      products: {
        Row: {
          id: string;
          name: string;
          description: string;
          category: string;
          base_price: number;
          discount_price: number | null;
          discount_start_date: string | null;
          discount_end_date: string | null;
          discount_active: boolean;
          purity_percentage: number;
          molecular_weight: string | null;
          cas_number: string | null;
          sequence: string | null;
          storage_conditions: string;
          inclusions: string[] | null;
          stock_quantity: number;
          available: boolean;
          featured: boolean;
          image_url: string | null;
          safety_sheet_url: string | null;
          code: string | null;
          spec: string | null;
          units_per_pack: number;
          unit_type: string;
          region_restriction: string | null;
          onhand_available: boolean;
          preorder_available: boolean;
          notes: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          name: string;
          description: string;
          category: string;
          base_price: number;
          discount_price?: number | null;
          discount_start_date?: string | null;
          discount_end_date?: string | null;
          discount_active?: boolean;
          purity_percentage?: number;
          molecular_weight?: string | null;
          cas_number?: string | null;
          sequence?: string | null;
          storage_conditions?: string;
          inclusions?: string[] | null;
          stock_quantity?: number;
          available?: boolean;
          featured?: boolean;
          image_url?: string | null;
          safety_sheet_url?: string | null;
          code?: string | null;
          spec?: string | null;
          units_per_pack?: number;
          unit_type?: string;
          region_restriction?: string | null;
          onhand_available?: boolean;
          preorder_available?: boolean;
          notes?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          name?: string;
          description?: string;
          category?: string;
          base_price?: number;
          discount_price?: number | null;
          discount_start_date?: string | null;
          discount_end_date?: string | null;
          discount_active?: boolean;
          purity_percentage?: number;
          molecular_weight?: string | null;
          cas_number?: string | null;
          sequence?: string | null;
          storage_conditions?: string;
          inclusions?: string[] | null;
          stock_quantity?: number;
          available?: boolean;
          featured?: boolean;
          image_url?: string | null;
          safety_sheet_url?: string | null;
          code?: string | null;
          spec?: string | null;
          units_per_pack?: number;
          unit_type?: string;
          region_restriction?: string | null;
          onhand_available?: boolean;
          preorder_available?: boolean;
          notes?: string | null;
          created_at?: string;
          updated_at?: string;
        };
      };
      product_prices: {
        Row: {
          id: string;
          product_id: string;
          price_type: string;
          currency: string;
          amount: number;
          min_qty: number;
          max_qty: number | null;
          is_override: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          product_id: string;
          price_type: string;
          currency?: string;
          amount: number;
          min_qty?: number;
          max_qty?: number | null;
          is_override?: boolean;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          product_id?: string;
          price_type?: string;
          currency?: string;
          amount?: number;
          min_qty?: number;
          max_qty?: number | null;
          is_override?: boolean;
          created_at?: string;
          updated_at?: string;
        };
      };
      product_variations: {
        Row: {
          id: string;
          product_id: string;
          name: string;
          quantity_mg: number;
          price: number;
          stock_quantity: number;
          created_at: string;
        };
        Insert: {
          id?: string;
          product_id: string;
          name: string;
          quantity_mg: number;
          price: number;
          stock_quantity?: number;
          created_at?: string;
        };
        Update: {
          id?: string;
          product_id?: string;
          name?: string;
          quantity_mg?: number;
          price?: number;
          stock_quantity?: number;
          created_at?: string;
        };
      };
      payment_methods: {
        Row: {
          id: string;
          name: string;
          account_number: string;
          account_name: string;
          qr_code_url: string;
          active: boolean;
          sort_order: number;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id: string;
          name: string;
          account_number: string;
          account_name: string;
          qr_code_url: string;
          active?: boolean;
          sort_order?: number;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          name?: string;
          account_number?: string;
          account_name?: string;
          qr_code_url?: string;
          active?: boolean;
          sort_order?: number;
          created_at?: string;
          updated_at?: string;
        };
      };
      site_settings: {
        Row: {
          id: string;
          value: string;
          type: string;
          description: string | null;
          updated_at: string;
        };
        Insert: {
          id: string;
          value: string;
          type?: string;
          description?: string | null;
          updated_at?: string;
        };
        Update: {
          id?: string;
          value?: string;
          type?: string;
          description?: string | null;
          updated_at?: string;
        };
      };
    };
  };
};
