import { describe, it, expect } from '@jest/globals';
import { validateConfig } from '../../src/validation';

describe('Configuration Validation', () => {
  it('should validate correct configuration', () => {
    const validConfig = {
      database: {
        url: 'postgresql://user:pass@localhost:5432/db',
      },
      server: {
        port: 3000,
        host: 'localhost',
      },
    };

    const result = validateConfig(validConfig);
    expect(result.isValid).toBe(true);
    expect(result.errors).toHaveLength(0);
  });

  it('should reject invalid configuration', () => {
    const invalidConfig = {
      database: {
        url: 'invalid-url',
      },
      server: {
        port: 'not-a-number',
        host: '',
      },
    };

    const result = validateConfig(invalidConfig);
    expect(result.isValid).toBe(false);
    expect(result.errors).toHaveLength(3);
  });
}); 