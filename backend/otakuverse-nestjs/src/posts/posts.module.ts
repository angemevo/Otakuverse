import { Module } from "@nestjs/common";
import { PostsController } from "./posts.controller";
import { PostsService } from "./posts.service";
import { DatabaseModule } from "@/database/database.module";


@Module({
    controllers: [PostsController],
    providers:[PostsService],
    exports:[PostsService],
    imports:[DatabaseModule]
})
export class PostsModule{}
// - Import DatabaseModule
// - Provider PostsService
