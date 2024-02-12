import { Controller, Get } from '@nestjs/common';

@Controller('example')
export class ExampleController {
  @Get()
  findAll() {
    return 'Status: Active';
  }
}
