SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: infection_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.infection_reports (
    id bigint NOT NULL,
    reporter_id bigint NOT NULL,
    reported_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: infection_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.infection_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: infection_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.infection_reports_id_seq OWNED BY public.infection_reports.id;


--
-- Name: inventories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventories (
    id bigint NOT NULL,
    quantity integer NOT NULL,
    kind integer NOT NULL,
    survivor_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: inventories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.inventories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.inventories_id_seq OWNED BY public.inventories.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: survivors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.survivors (
    id bigint NOT NULL,
    name character varying NOT NULL,
    age integer NOT NULL,
    gender integer NOT NULL,
    lat double precision NOT NULL,
    lon double precision NOT NULL,
    last_location public.geography(Point,4326) NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: survivors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.survivors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survivors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.survivors_id_seq OWNED BY public.survivors.id;


--
-- Name: infection_reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.infection_reports ALTER COLUMN id SET DEFAULT nextval('public.infection_reports_id_seq'::regclass);


--
-- Name: inventories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventories ALTER COLUMN id SET DEFAULT nextval('public.inventories_id_seq'::regclass);


--
-- Name: survivors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survivors ALTER COLUMN id SET DEFAULT nextval('public.survivors_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: infection_reports infection_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.infection_reports
    ADD CONSTRAINT infection_reports_pkey PRIMARY KEY (id);


--
-- Name: inventories inventories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventories
    ADD CONSTRAINT inventories_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: survivors survivors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survivors
    ADD CONSTRAINT survivors_pkey PRIMARY KEY (id);


--
-- Name: index_infection_reports_on_reported_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_infection_reports_on_reported_id ON public.infection_reports USING btree (reported_id);


--
-- Name: index_infection_reports_on_reporter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_infection_reports_on_reporter_id ON public.infection_reports USING btree (reporter_id);


--
-- Name: index_infection_reports_on_reporter_id_and_reported_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_infection_reports_on_reporter_id_and_reported_id ON public.infection_reports USING btree (reporter_id, reported_id);


--
-- Name: index_inventories_on_survivor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inventories_on_survivor_id ON public.inventories USING btree (survivor_id);


--
-- Name: index_inventories_on_survivor_id_and_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_inventories_on_survivor_id_and_kind ON public.inventories USING btree (survivor_id, kind);


--
-- Name: index_survivors_on_last_location; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_survivors_on_last_location ON public.survivors USING gist (last_location);


--
-- Name: inventories fk_rails_0492453b06; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventories
    ADD CONSTRAINT fk_rails_0492453b06 FOREIGN KEY (survivor_id) REFERENCES public.survivors(id);


--
-- Name: infection_reports fk_rails_93a14d202e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.infection_reports
    ADD CONSTRAINT fk_rails_93a14d202e FOREIGN KEY (reported_id) REFERENCES public.survivors(id);


--
-- Name: infection_reports fk_rails_b7f9e12bc7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.infection_reports
    ADD CONSTRAINT fk_rails_b7f9e12bc7 FOREIGN KEY (reporter_id) REFERENCES public.survivors(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20250523143323'),
('20250523041548'),
('20250522061131'),
('20250522042729');

