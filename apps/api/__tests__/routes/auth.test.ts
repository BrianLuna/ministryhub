import { app } from '../../src/app';

describe('Auth Routes', () => {
  describe('POST /api/auth/login', () => {
    it('should return 400 for invalid credentials', async () => {
      const response = await app.inject({
        method: 'POST',
        url: '/api/auth/login',
        payload: {
          email: 'invalid@example.com',
          password: 'wrongpassword',
        },
      });

      expect(response.statusCode).toBe(400);
      expect(JSON.parse(response.body)).toHaveProperty('error');
    });

    it('should return 200 and token for valid credentials', async () => {
      const response = await app.inject({
        method: 'POST',
        url: '/api/auth/login',
        payload: {
          email: 'test@example.com',
          password: 'validpassword',
        },
      });

      expect(response.statusCode).toBe(200);
      expect(JSON.parse(response.body)).toHaveProperty('token');
    });
  });
}); 