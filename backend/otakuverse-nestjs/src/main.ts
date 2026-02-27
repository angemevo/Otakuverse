import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  app.enableCors({
    origin: '*',
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    credentials: true,
  });
  
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
    }),
  );
  
  const port = process.env.PORT || 3000;
  await app.listen(port, '0.0.0.0');
  
  console.log(`\n🚀 Server running on http://localhost:${port}`);
  console.log(`📝 API Documentation: http://localhost:${port}`);
  console.log(`💚 Health check: http://localhost:${port}/health\n`);
}
bootstrap();
// - Bootstrap NestJS app
// - Configuration CORS
// - Configuration globale pipes/filters
// - Démarrage serveur
