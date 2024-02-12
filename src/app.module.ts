import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

import configuration from './config/configuration';
import { environment, validationSchemaEnv } from './config';
import { DatabaseModule } from './database/database.module';
import { ExampleModule } from './example/example.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      envFilePath: environment[process.env.NODE_ENV] || '.docker.env',
      //envFilePath: '.env',
      load: [configuration],
      isGlobal: true,
      cache: true,
      validationSchema: validationSchemaEnv,
    }),
    DatabaseModule,
    ExampleModule,
  ],
  controllers: [],
  providers: [],
})
export class AppModule {}
