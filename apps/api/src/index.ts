import Fastify from 'fastify';

const app = Fastify({
  logger: true, // Opcional: loggea los requests
});

// Ruta de prueba
app.get('/ping', async (request, reply) => {
  return { pong: true };
});

// Inicializar el servidor
const start = async () => {
  try {
    await app.listen({ port: 3001, host: '0.0.0.0' });
    console.log('🚀 API server listening on http://localhost:3001');
  } catch (err) {
    app.log.error(err);
    process.exit(1);
  }
};

start();
