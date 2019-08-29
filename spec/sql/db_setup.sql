CREATE TABLE "public"."posts" (
  id serial,
  title text,
  likes integer,
  published_at timestamp without time zone,
  PRIMARY KEY("id")
);
