import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Global validation: every incoming request body gets checked against
  // its DTO's class-validator decorators before it ever reaches a controller.
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // strips properties not defined in the DTO
      forbidNonWhitelisted: true, // rejects requests with unexpected extra fields
      transform: true, // auto-converts incoming JSON into DTO class instances
    }),
  );

  // Needed since Flutter web will call this API from a different origin.
  // Tighten to a specific origin before any real deployment.
  app.enableCors();

  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
