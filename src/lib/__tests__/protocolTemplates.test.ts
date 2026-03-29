import { describe, it, expect } from 'vitest';
import {
  protocolTemplates,
  getProtocolTemplate,
  generateProtocolFromTemplate,
} from '../protocolTemplates';

describe('protocolTemplates', () => {
  describe('protocolTemplates map', () => {
    it('contains all expected categories', () => {
      const expectedCategories = [
        'Weight Management',
        'Beauty & Anti-Aging',
        'Healing & Regeneration',
        'Longevity & Anti-Aging',
        'Cognitive Enhancement',
        'Sleep & Recovery',
        'Growth Hormone',
        'Metabolic Health',
        'Mitochondrial Health',
        'Anti-Inflammatory',
        'Sexual Wellness',
        'Detox & Skin Brightening',
        'Fat Burning & Energy',
        'Fat Dissolving',
        'Healing & Anti-Inflammatory',
        'Tanning & Aesthetics',
        'default',
      ];

      for (const cat of expectedCategories) {
        expect(protocolTemplates[cat]).toBeDefined();
      }
    });

    it('each template has required fields', () => {
      for (const [category, template] of Object.entries(protocolTemplates)) {
        expect(template.dosage).toBeTypeOf('string');
        expect(template.frequency).toBeTypeOf('string');
        expect(template.duration).toBeTypeOf('string');
        expect(template.storage).toBeTypeOf('string');
        expect(Array.isArray(template.notes)).toBe(true);
        expect(template.notes.length).toBeGreaterThan(0);
      }
    });
  });

  describe('getProtocolTemplate', () => {
    it('returns the correct template for a known category', () => {
      const template = getProtocolTemplate('Weight Management');
      expect(template.dosage).toContain('weekly');
      expect(template.frequency).toContain('Once weekly');
    });

    it('returns default template for an unknown category', () => {
      const template = getProtocolTemplate('Nonexistent Category');
      expect(template).toBe(protocolTemplates['default']);
      expect(template.dosage).toContain('Consult');
    });

    it('returns the specific category template, not default', () => {
      const template = getProtocolTemplate('Cognitive Enhancement');
      expect(template).toBe(protocolTemplates['Cognitive Enhancement']);
      expect(template).not.toBe(protocolTemplates['default']);
    });
  });

  describe('generateProtocolFromTemplate', () => {
    it('generates a protocol object with correct structure', () => {
      const protocol = generateProtocolFromTemplate('BPC-157', 'Healing & Regeneration');

      expect(protocol.name).toBe('BPC-157 Protocol');
      expect(protocol.category).toBe('Healing & Regeneration');
      expect(protocol.dosage).toBe(protocolTemplates['Healing & Regeneration'].dosage);
      expect(protocol.frequency).toBe(protocolTemplates['Healing & Regeneration'].frequency);
      expect(protocol.duration).toBe(protocolTemplates['Healing & Regeneration'].duration);
      expect(protocol.notes).toEqual(protocolTemplates['Healing & Regeneration'].notes);
      expect(protocol.storage).toBe(protocolTemplates['Healing & Regeneration'].storage);
      expect(protocol.sort_order).toBe(0);
      expect(protocol.active).toBe(true);
    });

    it('uses default template for unknown categories', () => {
      const protocol = generateProtocolFromTemplate('TestPeptide', 'Unknown');
      expect(protocol.name).toBe('TestPeptide Protocol');
      expect(protocol.category).toBe('Unknown');
      expect(protocol.dosage).toBe(protocolTemplates['default'].dosage);
    });

    it('includes all template notes', () => {
      const protocol = generateProtocolFromTemplate('GHK-Cu', 'Beauty & Anti-Aging');
      expect(protocol.notes).toHaveLength(protocolTemplates['Beauty & Anti-Aging'].notes.length);
    });
  });
});
