import { DataSourceOptions, DataSource } from 'typeorm';
import { join } from 'path';

import * as dotenv from 'dotenv';
dotenv.config({ path: '.docker.env' });

export const dataSourceOptions: DataSourceOptions = {
  type: 'postgres',
  host: process.env.DATABASE_HOST,
  port: +process.env.DATABASE_PORT,
  username: process.env.DATABASE_USER,
  password: process.env.DATABASE_PASSWORD,
  database: process.env.DATABASE_DB_NAME,
  logging: true,
  synchronize: false,
  entities: [join(__dirname, '../**/*.entity.ts')],
  migrations: [join(__dirname, '../../migrations/*.ts')],
  migrationsTableName: 'migrations',
};

const AppDataSource = new DataSource(dataSourceOptions);
export default AppDataSource;
