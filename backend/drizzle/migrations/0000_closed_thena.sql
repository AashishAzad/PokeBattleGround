CREATE TYPE "public"."game_mode" AS ENUM('single', 'multi');--> statement-breakpoint
CREATE TYPE "public"."game_type" AS ENUM('higher_or_lower', 'type_clash', 'who_is_that_pokemon');--> statement-breakpoint
CREATE TABLE "game_scores" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"game_type" "game_type" NOT NULL,
	"mode" "game_mode" NOT NULL,
	"score" integer NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "users" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"username" varchar(32) NOT NULL,
	"password_hash" varchar(255) NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "users_username_unique" UNIQUE("username")
);
--> statement-breakpoint
ALTER TABLE "game_scores" ADD CONSTRAINT "game_scores_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "leaderboard_idx" ON "game_scores" USING btree ("game_type","score");--> statement-breakpoint
CREATE INDEX "user_scores_idx" ON "game_scores" USING btree ("user_id");