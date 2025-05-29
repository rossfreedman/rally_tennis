--
-- PostgreSQL database dump
--

-- Dumped from database version 15.13 (Homebrew)
-- Dumped by pg_dump version 15.13 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: normalize_match_date(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.normalize_match_date(input_date text, tz text DEFAULT 'America/Chicago'::text) RETURNS timestamp with time zone
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
RETURN (input_date || ' 12:00:00')::timestamp AT TIME ZONE tz;
END;
$$;


ALTER FUNCTION public.normalize_match_date(input_date text, tz text) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO postgres;

--
-- Name: clubs; Type: TABLE; Schema: public; Owner: rossfreedman
--

CREATE TABLE public.clubs (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    address character varying(500)
);


ALTER TABLE public.clubs OWNER TO rossfreedman;

--
-- Name: clubs_id_seq; Type: SEQUENCE; Schema: public; Owner: rossfreedman
--

CREATE SEQUENCE public.clubs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.clubs_id_seq OWNER TO rossfreedman;

--
-- Name: clubs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: rossfreedman
--

ALTER SEQUENCE public.clubs_id_seq OWNED BY public.clubs.id;


--
-- Name: player_availability; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.player_availability (
    id integer NOT NULL,
    player_name character varying(255) NOT NULL,
    availability_status integer DEFAULT 3 NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    series_id integer NOT NULL,
    match_date timestamp with time zone NOT NULL,
    CONSTRAINT valid_availability_status CHECK ((availability_status = ANY (ARRAY[1, 2, 3])))
);


ALTER TABLE public.player_availability OWNER TO postgres;

--
-- Name: player_availability_backup; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.player_availability_backup (
    id integer,
    player_name character varying(255),
    match_date date,
    availability_status integer,
    updated_at timestamp without time zone,
    series_id integer
);


ALTER TABLE public.player_availability_backup OWNER TO postgres;

--
-- Name: player_availability_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.player_availability_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.player_availability_id_seq OWNER TO postgres;

--
-- Name: player_availability_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.player_availability_id_seq OWNED BY public.player_availability.id;


--
-- Name: series; Type: TABLE; Schema: public; Owner: rossfreedman
--

CREATE TABLE public.series (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.series OWNER TO rossfreedman;

--
-- Name: series_id_seq; Type: SEQUENCE; Schema: public; Owner: rossfreedman
--

CREATE SEQUENCE public.series_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.series_id_seq OWNER TO rossfreedman;

--
-- Name: series_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: rossfreedman
--

ALTER SEQUENCE public.series_id_seq OWNED BY public.series.id;


--
-- Name: user_activity_logs; Type: TABLE; Schema: public; Owner: rossfreedman
--

CREATE TABLE public.user_activity_logs (
    id integer NOT NULL,
    user_email character varying(255) NOT NULL,
    activity_type character varying(255) NOT NULL,
    page character varying(255),
    action text,
    details text,
    ip_address character varying(45),
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_activity_logs OWNER TO rossfreedman;

--
-- Name: user_activity_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: rossfreedman
--

CREATE SEQUENCE public.user_activity_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_activity_logs_id_seq OWNER TO rossfreedman;

--
-- Name: user_activity_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: rossfreedman
--

ALTER SEQUENCE public.user_activity_logs_id_seq OWNED BY public.user_activity_logs.id;


--
-- Name: user_instructions; Type: TABLE; Schema: public; Owner: rossfreedman
--

CREATE TABLE public.user_instructions (
    id integer NOT NULL,
    user_email character varying(255) NOT NULL,
    instruction text NOT NULL,
    team_id integer,
    created_at timestamp without time zone,
    is_active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.user_instructions OWNER TO rossfreedman;

--
-- Name: user_instructions_id_seq; Type: SEQUENCE; Schema: public; Owner: rossfreedman
--

CREATE SEQUENCE public.user_instructions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_instructions_id_seq OWNER TO rossfreedman;

--
-- Name: user_instructions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: rossfreedman
--

ALTER SEQUENCE public.user_instructions_id_seq OWNED BY public.user_instructions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: rossfreedman
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    club_id integer,
    series_id integer,
    club_automation_password character varying(255),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_login timestamp without time zone,
    is_admin boolean DEFAULT false NOT NULL
);


ALTER TABLE public.users OWNER TO rossfreedman;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: rossfreedman
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO rossfreedman;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: rossfreedman
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: clubs id; Type: DEFAULT; Schema: public; Owner: rossfreedman
--

ALTER TABLE ONLY public.clubs ALTER COLUMN id SET DEFAULT nextval('public.clubs_id_seq'::regclass);


--
-- Name: player_availability id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_availability ALTER COLUMN id SET DEFAULT nextval('public.player_availability_id_seq'::regclass);


--
-- Name: series id; Type: DEFAULT; Schema: public; Owner: rossfreedman
--

ALTER TABLE ONLY public.series ALTER COLUMN id SET DEFAULT nextval('public.series_id_seq'::regclass);


--
-- Name: user_activity_logs id; Type: DEFAULT; Schema: public; Owner: rossfreedman
--

ALTER TABLE ONLY public.user_activity_logs ALTER COLUMN id SET DEFAULT nextval('public.user_activity_logs_id_seq'::regclass);


--
-- Name: user_instructions id; Type: DEFAULT; Schema: public; Owner: rossfreedman
--

ALTER TABLE ONLY public.user_instructions ALTER COLUMN id SET DEFAULT nextval('public.user_instructions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: rossfreedman
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alembic_version (version_num) FROM stdin;
c30453403ba8
\.


--
-- Data for Name: clubs; Type: TABLE DATA; Schema: public; Owner: rossfreedman
--

COPY public.clubs (id, name, address) FROM stdin;
181	Birchwood	1174 Park Ave W, Highland Park, IL 60035
12	Lake Forest	554 North Westmoreland Road, Lake Forest, IL 60045
182	Ravinia Green	1200 Saunders road, Riverwoods, Illinois 60015
4	Winnetka	530 Hibbard Road, Winnetka IL 60093
1	Tennaqua	1 Tennaqua Lane (Deerfield Rd. & Castlewood Rd.), Deerfield, IL 60015
18	Butterfield	26W011 Butterfield Rd, Wheaton, IL 60189
10	Glen View	800 Greenwood Ave, Glenview, IL 60025
6	Hinsdale PC	6200 S County Line Rd, Hinsdale, IL 60521
31	Michigan Shores	911 Sheridan Rd, Wilmette, IL 60091
29	North Shore	1340 Northshore Ave, Highland Park, IL 60035
7	Onwentsia	300 Green Bay Rd, Lake Forest, IL 60045
23	Westmoreland	4939 S Drexel Blvd, Chicago, IL 60615
183	Wilmette	1200 Wilmette Ave, Wilmette, IL 60091
\.


--
-- Data for Name: player_availability; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.player_availability (id, player_name, availability_status, updated_at, series_id, match_date) FROM stdin;
93	Greg Swender	1	2025-05-23 17:12:09.882168	182	2024-10-01 12:00:00-05
94	Greg Swender	2	2025-05-23 17:12:10.623372	182	2024-09-24 12:00:00-05
112	Ross Freedman	1	2025-05-24 17:14:27.569447	182	2024-09-24 12:00:00-05
113	Ross Freedman	2	2025-05-24 17:14:29.369779	182	2024-10-01 12:00:00-05
7	Ross Freedman	2	2025-05-20 19:41:57.717913	183	2024-10-22 12:00:00-05
75	Mike Lieberman	1	2025-05-22 15:12:41.328897	183	2024-09-24 12:00:00-05
76	Mike Lieberman	1	2025-05-22 15:12:42.140562	183	2024-10-01 12:00:00-05
77	Mike Lieberman	2	2025-05-22 15:12:43.75464	183	2024-10-08 12:00:00-05
78	Mike Lieberman	3	2025-05-22 15:12:45.069993	183	2024-10-15 12:00:00-05
26	Ross Freedman	1	2025-05-21 11:11:39.886919	183	2024-11-12 12:00:00-06
9	Ross Freedman	2	2025-05-21 11:12:06.991425	183	2024-11-05 12:00:00-06
79	Mike Lieberman	2	2025-05-22 15:12:46.60842	183	2024-10-22 12:00:00-05
21	Ross Freedman	2	2025-05-21 11:13:38.099216	183	2024-10-29 12:00:00-05
80	Mike Lieberman	1	2025-05-22 15:12:48.251991	183	2024-11-05 12:00:00-06
81	Mike Lieberman	2	2025-05-22 15:12:50.20956	183	2024-11-12 12:00:00-06
82	Mike Lieberman	1	2025-05-22 15:12:51.547028	183	2024-11-19 12:00:00-06
84	Jonathan Blume	2	2025-05-23 08:06:11.850031	183	2024-10-01 12:00:00-05
85	Jonathan Blume	3	2025-05-23 08:06:13.37578	183	2024-10-08 12:00:00-05
83	Jonathan Blume	1	2025-05-23 08:06:09.944296	183	2024-09-24 12:00:00-05
4	Ross Freedman	3	2025-05-21 11:16:17.264522	183	2024-10-08 12:00:00-05
92	Greg Swender	1	2025-05-23 17:06:05.92283	183	2024-09-24 12:00:00-05
3	Ross Freedman	1	2025-05-21 12:31:39.204224	183	2024-10-01 12:00:00-05
6	Ross Freedman	2	2025-05-21 11:16:18.380752	183	2024-10-15 12:00:00-05
1	Ross Freedman	2	2025-05-24 17:15:01.011282	183	2024-09-24 12:00:00-05
104	Scott Osterman	2	2025-05-24 09:37:15.365479	184	2024-09-26 12:00:00-05
106	Scott Osterman	3	2025-05-24 09:37:19.764922	184	2024-10-03 12:00:00-05
107	Scott Osterman	3	2025-05-24 09:37:43.627599	184	2024-10-10 12:00:00-05
108	Scott Osterman	3	2025-05-24 09:38:30.580745	184	2024-11-14 12:00:00-06
109	Scott Osterman	2	2025-05-24 09:38:36.562465	184	2024-11-07 12:00:00-06
121	Ross Freedman	1	2025-05-26 13:02:40.600152	184	2025-05-29 12:00:00-05
123	Ross Freedman	2	2025-05-27 12:30:06.708827	184	2025-06-02 12:00:00-05
90	Jeffrey Condren	2	2025-05-23 08:52:12.830543	184	2025-05-29 12:00:00-05
116	Ross Freedman	1	2025-05-27 23:01:16.052379	184	2025-05-26 12:00:00-05
141	Jeff Condren	3	2025-05-28 16:50:56.13212	184	2025-05-26 12:00:00-05
\.


--
-- Data for Name: player_availability_backup; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.player_availability_backup (id, player_name, match_date, availability_status, updated_at, series_id) FROM stdin;
93	Greg Swender	2024-10-01	1	2025-05-23 17:12:09.882168	182
94	Greg Swender	2024-09-24	2	2025-05-23 17:12:10.623372	182
112	Ross Freedman	2024-09-24	1	2025-05-24 17:14:27.569447	182
113	Ross Freedman	2024-10-01	2	2025-05-24 17:14:29.369779	182
7	Ross Freedman	2024-10-22	2	2025-05-20 19:41:57.717913	183
75	Mike Lieberman	2024-09-24	1	2025-05-22 15:12:41.328897	183
76	Mike Lieberman	2024-10-01	1	2025-05-22 15:12:42.140562	183
77	Mike Lieberman	2024-10-08	2	2025-05-22 15:12:43.75464	183
78	Mike Lieberman	2024-10-15	3	2025-05-22 15:12:45.069993	183
26	Ross Freedman	2024-11-12	1	2025-05-21 11:11:39.886919	183
9	Ross Freedman	2024-11-05	2	2025-05-21 11:12:06.991425	183
79	Mike Lieberman	2024-10-22	2	2025-05-22 15:12:46.60842	183
21	Ross Freedman	2024-10-29	2	2025-05-21 11:13:38.099216	183
80	Mike Lieberman	2024-11-05	1	2025-05-22 15:12:48.251991	183
81	Mike Lieberman	2024-11-12	2	2025-05-22 15:12:50.20956	183
82	Mike Lieberman	2024-11-19	1	2025-05-22 15:12:51.547028	183
84	Jonathan Blume	2024-10-01	2	2025-05-23 08:06:11.850031	183
85	Jonathan Blume	2024-10-08	3	2025-05-23 08:06:13.37578	183
83	Jonathan Blume	2024-09-24	1	2025-05-23 08:06:09.944296	183
4	Ross Freedman	2024-10-08	3	2025-05-21 11:16:17.264522	183
92	Greg Swender	2024-09-24	1	2025-05-23 17:06:05.92283	183
3	Ross Freedman	2024-10-01	1	2025-05-21 12:31:39.204224	183
6	Ross Freedman	2024-10-15	2	2025-05-21 11:16:18.380752	183
1	Ross Freedman	2024-09-24	2	2025-05-24 17:15:01.011282	183
104	Scott Osterman	2024-09-26	2	2025-05-24 09:37:15.365479	184
106	Scott Osterman	2024-10-03	3	2025-05-24 09:37:19.764922	184
107	Scott Osterman	2024-10-10	3	2025-05-24 09:37:43.627599	184
108	Scott Osterman	2024-11-14	3	2025-05-24 09:38:30.580745	184
109	Scott Osterman	2024-11-07	2	2025-05-24 09:38:36.562465	184
121	Ross Freedman	2025-05-29	1	2025-05-26 13:02:40.600152	184
123	Ross Freedman	2025-06-02	2	2025-05-27 12:30:06.708827	184
90	Jeffrey Condren	2025-05-29	2	2025-05-23 08:52:12.830543	184
116	Ross Freedman	2025-05-26	1	2025-05-27 23:01:16.052379	184
141	Jeff Condren	2025-05-26	3	2025-05-28 16:50:56.13212	184
\.


--
-- Data for Name: series; Type: TABLE DATA; Schema: public; Owner: rossfreedman
--

COPY public.series (id, name) FROM stdin;
182	Series 1
183	Series 2A
184	Series 2B
185	Series 3
\.


--
-- Data for Name: user_activity_logs; Type: TABLE DATA; Schema: public; Owner: rossfreedman
--

COPY public.user_activity_logs (id, user_email, activity_type, page, action, details, ip_address, "timestamp") FROM stdin;
12512	rossfreedman@gmail.com	auth	\N	register	User registered successfully	127.0.0.1	2025-05-18 11:31:24.519266
12513	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 11:31:24.53512
12514	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 11:31:24.644658
12515	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 11:31:26.405018
12516	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 11:31:28.51398
12517	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 11:31:28.577514
12518	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 11:31:30.034995
12519	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 11:31:31.143947
12520	rossfreedman@gmail.com	auth	\N	login	Successful login	127.0.0.1	2025-05-18 11:31:38.287177
12521	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 11:31:38.30509
12522	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 11:31:38.368789
12523	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 11:31:39.400058
12524	rossfreedman@gmail.com	static_asset	favicon	\N	Accessed static asset: favicon.ico	127.0.0.1	2025-05-18 11:31:39.428312
12525	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 11:31:41.501289
12526	rossfreedman@gmail.com	auth	\N	login	Successful login	127.0.0.1	2025-05-18 12:08:07.433343
12527	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:08:07.456645
12528	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:08:07.563388
12529	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:08:08.850753
12530	rossfreedman@gmail.com	auth	\N	login	Successful login	127.0.0.1	2025-05-18 12:10:29.188096
12531	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:10:29.200547
12532	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:10:29.27409
12533	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:10:31.899906
12534	rossfreedman@gmail.com	auth	\N	login	Successful login	127.0.0.1	2025-05-18 12:10:50.538346
12535	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:10:50.552098
12536	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:10:50.60991
12537	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:10:54.746072
12538	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-18 12:10:54.834335
12539	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:10:54.927758
12540	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:10:57.557974
12541	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:10:58.258499
12542	rossfreedman@gmail.com	auth	\N	login	Successful login	127.0.0.1	2025-05-18 12:11:55.734712
12543	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:11:55.749997
12544	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:11:55.835183
12545	rossfreedman@gmail.com	auth	\N	login	Successful login	127.0.0.1	2025-05-18 12:16:59.72559
12546	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:16:59.743458
12547	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:16:59.853419
12548	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:17:00.858189
12549	rossfreedman@gmail.com	auth	\N	login	Successful login	127.0.0.1	2025-05-18 12:17:22.534051
12550	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:17:22.546584
12551	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:17:22.612911
12552	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:17:53.282488
12553	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-18 12:17:53.309826
12554	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:17:53.404079
12555	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:17:59.614214
12556	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:18:01.460754
12557	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:18:02.355208
12558	rossfreedman@gmail.com	auth	\N	login	Successful login	127.0.0.1	2025-05-18 12:19:41.571291
12559	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:19:41.588975
12560	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:19:41.677166
12561	rossfreedman@gmail.com	page_visit	\N	view_schedule	Viewed 71 matches	127.0.0.1	2025-05-18 12:19:42.539207
12562	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:19:42.538539
12563	rossfreedman@gmail.com	auth	\N	login	Successful login	127.0.0.1	2025-05-18 12:22:02.067652
12564	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:22:02.084003
12565	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:22:02.161017
12566	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:22:03.113668
12567	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:22:03.118334
12568	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:22:03.141732
12569	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:22:03.200663
12570	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:22:04.074152
12571	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:22:04.083143
12572	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:22:04.093604
12573	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:22:04.151156
12574	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:22:05.091584
12575	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:22:05.101545
12576	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:22:05.117704
12577	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:22:05.175332
12578	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:23:48.454225
12579	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:23:48.461313
12580	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:23:48.47206
12581	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:23:48.52114
12582	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:23:53.491883
12583	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:23:55.379268
12584	rossfreedman@gmail.com	auth	\N	login	Successful login	127.0.0.1	2025-05-18 12:27:02.426506
12585	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:27:02.443107
12586	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:27:02.535592
12588	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:27:03.587774
13757	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 14:08:18.29964
13760	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:08:18.386627
13763	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:08:19.134322
13766	rossfreedman@gmail.com	click	/mobile	button	button: 	127.0.0.1	2025-05-18 14:08:19.921075
13769	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 14:08:21.613574
13772	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:08:21.67366
13775	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:12:09.096709
13778	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:12:09.65748
13779	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:12:09.657367
13782	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 14:12:12.876896
13787	rossfreedman@gmail.com	click	/mobile	a	a: View Schedule -> http://127.0.0.1:8080/mobile/view-schedule	127.0.0.1	2025-05-18 16:44:36.011488
13790	rossfreedman@gmail.com	click	/mobile/view-schedule	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 16:44:37.60608
13791	rossfreedman@gmail.com	click	/mobile/view-schedule	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 16:44:37.605979
13794	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 16:44:42.634298
13795	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 16:44:42.634229
13799	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 16:44:43.086564
13803	rossfreedman@gmail.com	click	/mobile/availability	a	a: Logout -> http://127.0.0.1:8080/mobile/availability#	127.0.0.1	2025-05-18 16:44:47.491367
13807	rossfreedman@gmail.com	click	/mobile/availability	a	a: Logout -> http://127.0.0.1:8080/mobile/availability#	127.0.0.1	2025-05-18 16:44:49.130921
13806	rossfreedman@gmail.com	click	/mobile/availability	a	a: Logout -> http://127.0.0.1:8080/mobile/availability#	127.0.0.1	2025-05-18 16:44:49.130973
13811	rossfreedman@gmail.com	click	/mobile/availability	a	a: Logout -> http://127.0.0.1:8080/mobile/availability#	127.0.0.1	2025-05-18 16:44:49.82576
13815	rossfreedman@gmail.com	click	/mobile/availability	a	a: Logout -> http://127.0.0.1:8080/mobile/availability#	127.0.0.1	2025-05-18 16:44:50.290719
13819	rossfreedman@gmail.com	click	/mobile/availability	a	a: Improve my game -> http://127.0.0.1:8080/mobile/improve	127.0.0.1	2025-05-18 16:46:28.260401
13821	rossfreedman@gmail.com	click	/mobile/improve	button	button: 	127.0.0.1	2025-05-18 16:46:29.09391
13825	rossfreedman@gmail.com	click	/mobile/improve	a	a: Logout -> http://127.0.0.1:8080/mobile/improve#	127.0.0.1	2025-05-18 16:46:41.257395
13828	rossfreedman@gmail.com	click	/mobile/improve	a	a: Logout -> http://127.0.0.1:8080/mobile/improve#	127.0.0.1	2025-05-18 16:47:10.037935
13830	rossfreedman@gmail.com	click	/mobile/improve	button	button: 	127.0.0.1	2025-05-18 16:48:11.333259
13834	rossfreedman@gmail.com	click	/mobile/improve	a	a: Improve my game -> http://127.0.0.1:8080/mobile/improve	127.0.0.1	2025-05-18 16:48:12.645374
13837	rossfreedman@gmail.com	click	/mobile/improve	a	a: My Club -> http://127.0.0.1:8080/mobile/my-club	127.0.0.1	2025-05-18 16:48:14.650645
13841	rossfreedman@gmail.com	click	/mobile/my-club	a	a: Logout -> http://127.0.0.1:8080/mobile/my-club#	127.0.0.1	2025-05-18 16:48:21.993746
13845	rossfreedman@gmail.com	click	/mobile/my-club	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 17:04:40.5098
13844	rossfreedman@gmail.com	click	/mobile/my-club	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 17:04:40.510017
13848	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 17:04:43.10392
13851	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 17:04:43.523972
13854	rossfreedman@gmail.com	click	/mobile/availability	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 17:04:44.735381
13857	rossfreedman@gmail.com	click	/mobile	button	button: 	127.0.0.1	2025-05-18 17:04:48.571481
13860	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 17:04:51.46964
13864	rossfreedman@gmail.com	click	/mobile	a	a: Lineup Escrow -> http://127.0.0.1:8080/mobile/lineup-escrow	127.0.0.1	2025-05-18 17:04:52.288399
13867	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 17:06:20.550816
13870	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 17:06:24.151262
13871	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 17:06:24.150999
13874	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 17:07:04.119663
13879	rossfreedman@gmail.com	click	/mobile/availability	a	a: Logout -> http://127.0.0.1:8080/mobile/availability#	127.0.0.1	2025-05-18 17:07:07.214505
13878	rossfreedman@gmail.com	click	/mobile/availability	a	a: Logout -> http://127.0.0.1:8080/mobile/availability#	127.0.0.1	2025-05-18 17:07:07.214543
13883	rossfreedman@gmail.com	click	/mobile/availability	button	button: 	127.0.0.1	2025-05-18 17:08:15.611713
13885	rossfreedman@gmail.com	click	/mobile/availability	a	a: Logout -> http://127.0.0.1:8080/mobile/availability#	127.0.0.1	2025-05-18 17:08:18.20556
13890	rossfreedman@gmail.com	click	/mobile	button	button: 	127.0.0.1	2025-05-18 17:26:06.571177
13894	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 17:26:10.451767
13893	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 17:26:10.451715
13900	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 17:26:11.25193
13899	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 17:26:11.251878
13903	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 17:26:11.592955
13907	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 17:27:18.121574
12589	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:27:03.66169
12609	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:29:08.801451
12629	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:31:35.716173
12650	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:35:10.322789
12671	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:14.125919
12691	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:26.128411
12713	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:35.150153
12733	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:05.266397
12754	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:37:15.386789
12774	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:37:23.550343
12796	rossfreedman@gmail.com	click	/mobile	a	a: View Schedule -> http://127.0.0.1:8080/mobile/view-schedule	127.0.0.1	2025-05-18 12:37:40.758748
12797	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:37:40.758786
12817	rossfreedman@gmail.com	click	/mobile	a	a: My Team -> http://127.0.0.1:8080/mobile/myteam	127.0.0.1	2025-05-18 12:38:33.292398
12837	rossfreedman@gmail.com	click	/mobile/analyze-me	page_visit	page_visit: Rally -> /mobile/analyze-me	127.0.0.1	2025-05-18 12:38:37.471969
12859	rossfreedman@gmail.com	click	/mobile/ask-ai	page_visit	page_visit: Rally -> /mobile/ask-ai	127.0.0.1	2025-05-18 12:38:53.426655
12880	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:42:07.966549
12902	rossfreedman@gmail.com	click	/mobile	a	a: Ask Rally AI -> http://127.0.0.1:8080/mobile/ask-ai	127.0.0.1	2025-05-18 12:42:11.698947
12921	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:44:21.465685
12942	rossfreedman@gmail.com	click	/mobile	a	a: My Team -> http://127.0.0.1:8080/mobile/myteam	127.0.0.1	2025-05-18 12:44:26.193029
12962	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:52:13.738152
12985	rossfreedman@gmail.com	click	/mobile/myteam	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 12:52:33.084474
13006	rossfreedman@gmail.com	click	/mobile/find-subs	page_visit	page_visit: Rally -> /mobile/find-subs	127.0.0.1	2025-05-18 12:52:49.269519
13027	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:57:06.536759
13048	rossfreedman@gmail.com	click	/mobile/improve	page_visit	page_visit: Rally -> /mobile/improve	127.0.0.1	2025-05-18 12:58:32.918905
13069	rossfreedman@gmail.com	click	/mobile/analyze-me	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 13:01:58.786576
13089	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:02:18.440668
13110	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:07:40.97572
13130	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:09:52.753783
13151	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:14:18.485536
13171	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:17:00.086647
13190	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:22:24.421992
13210	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:28:53.942608
13233	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:32:27.496791
13253	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:33:57.257474
13273	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:35:11.148576
13294	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:35:20.930492
13314	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:35:40.487175
13334	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:37:53.557274
13355	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:38:22.814252
13375	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:38:33.622361
13397	rossfreedman@gmail.com	click	/mobile/availability	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 13:39:02.063426
13416	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:46:58.743098
13417	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:46:58.743417
13437	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:47:43.639717
13457	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:47:57.743521
13477	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:48:15.203155
13501	rossfreedman@gmail.com	click	/mobile	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 13:48:32.765199
13521	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:50:52.42348
13541	rossfreedman@gmail.com	click	/mobile/my-series	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 13:50:59.495388
13562	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:52:19.066578
13583	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:52:22.219135
13603	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:54:59.242536
13623	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:55:09.344688
13644	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:56:27.151625
13643	rossfreedman@gmail.com	click	/mobile/availability	a	a: Logout -> http://127.0.0.1:8080/mobile/availability#	127.0.0.1	2025-05-18 13:56:27.151593
13664	rossfreedman@gmail.com	click	/mobile/my-club	a	a: Logout -> http://127.0.0.1:8080/mobile/my-club#	127.0.0.1	2025-05-18 13:59:00.256604
13685	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 14:01:36.391237
13706	rossfreedman@gmail.com	click	/mobile/availability	button	button: 	127.0.0.1	2025-05-18 14:03:49.967989
12590	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:27:05.241655
12610	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:29:09.792896
12630	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:31:46.98078
12651	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:35:11.113028
12672	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:36:15.029584
12692	rossfreedman@gmail.com	page_visit	mobile_player_detail	\N	Viewed player Brian Rosenburg	127.0.0.1	2025-05-18 12:36:26.152887
12714	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:35.15463
12735	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:05.351205
12755	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:37:15.397071
12776	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:23.617188
12775	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:23.617195
12798	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:37:40.770687
12818	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:38:33.294856
12838	rossfreedman@gmail.com	click	/mobile/analyze-me	page_visit	page_visit: Rally -> /mobile/analyze-me	127.0.0.1	2025-05-18 12:38:37.471934
12860	rossfreedman@gmail.com	click	/mobile/ask-ai	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 12:38:54.484088
12883	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:42:08.082907
12903	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	Accessed Ask AI page	127.0.0.1	2025-05-18 12:42:11.698963
12922	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:44:22.002504
12943	rossfreedman@gmail.com	click	/mobile/myteam	page_visit	page_visit: Rally -> /mobile/myteam	127.0.0.1	2025-05-18 12:44:26.269977
12963	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 12:52:23.779837
12986	rossfreedman@gmail.com	click	/mobile	a	a: My Series -> http://127.0.0.1:8080/mobile/myseries	127.0.0.1	2025-05-18 12:52:33.93173
13007	rossfreedman@gmail.com	click	/mobile/find-subs	page_visit	page_visit: Rally -> /mobile/find-subs	127.0.0.1	2025-05-18 12:52:49.272194
13029	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:57:06.607054
13047	rossfreedman@gmail.com	click	/mobile/improve	page_visit	page_visit: Rally -> /mobile/improve	127.0.0.1	2025-05-18 12:58:32.918732
13070	rossfreedman@gmail.com	click	/mobile	a	a: View Schedule -> http://127.0.0.1:8080/mobile/view-schedule	127.0.0.1	2025-05-18 13:01:59.384189
13090	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:04:31.81485
13111	rossfreedman@gmail.com	click	/mobile	a	a: View Schedule -> http://127.0.0.1:8080/mobile/view-schedule	127.0.0.1	2025-05-18 13:07:41.323146
13131	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:09:56.098226
13152	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:14:18.485456
13172	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 13:17:00.549625
13192	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:22:24.427056
13212	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:28:53.947279
13234	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 13:32:28.154658
13254	rossfreedman@gmail.com	click	/mobile	a	a: View Schedule -> http://127.0.0.1:8080/mobile/view-schedule	127.0.0.1	2025-05-18 13:33:57.764727
13274	rossfreedman@gmail.com	click	/mobile/availability	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 13:35:11.152109
13295	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:35:20.930467
13315	rossfreedman@gmail.com	click	/mobile/availability	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 13:35:40.489675
13335	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:37:53.754515
13356	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:38:23.556378
13377	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:38:33.627204
13396	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:39:02.063193
13418	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:46:58.747614
13438	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 10/01/2024, Available: True	127.0.0.1	2025-05-18 13:47:43.649252
13458	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:47:57.905839
13478	rossfreedman@gmail.com	click	/mobile/availability	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 13:48:15.203127
13500	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:48:32.765254
13523	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:50:52.428595
13542	rossfreedman@gmail.com	page_visit	mobile_lineup	\N	\N	127.0.0.1	2025-05-18 13:51:01.199079
13563	rossfreedman@gmail.com	click	/mobile	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 13:52:19.069901
13584	rossfreedman@gmail.com	static_asset	com.chrome.devtools	\N	Accessed static asset: .well-known/appspecific/com.chrome.devtools.json	127.0.0.1	2025-05-18 13:52:35.698563
13604	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:54:59.37654
13624	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:55:09.344594
13645	rossfreedman@gmail.com	auth	\N	logout	\N	127.0.0.1	2025-05-18 13:56:27.151545
13665	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:59:00.308444
13687	rossfreedman@gmail.com	auth	\N	logout	\N	127.0.0.1	2025-05-18 14:01:36.391221
13708	rossfreedman@gmail.com	auth	\N	logout	\N	127.0.0.1	2025-05-18 14:03:51.714225
13707	rossfreedman@gmail.com	click	/mobile/availability	a	a: Logout -> http://127.0.0.1:8080/mobile/availability#	127.0.0.1	2025-05-18 14:03:51.714192
13709	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 14:03:51.714145
13726	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 14:05:05.447138
12591	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:27:06.028139
12611	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:29:10.581112
12631	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:31:47.100747
12652	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:35:11.694382
12673	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:15.037999
12693	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:26.243674
12715	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:36:46.715002
12736	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:05.35109
12756	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:15.460959
12777	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:23.621253
12799	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:37:40.830387
12820	rossfreedman@gmail.com	click	/mobile/myteam	page_visit	page_visit: Rally -> /mobile/myteam	127.0.0.1	2025-05-18 12:38:33.366889
12839	rossfreedman@gmail.com	click	/mobile/analyze-me	page_visit	page_visit: Rally -> /mobile/analyze-me	127.0.0.1	2025-05-18 12:38:37.475959
12861	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:38:56.600826
12881	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:42:08.082963
12901	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:42:11.699201
12923	rossfreedman@gmail.com	click	/mobile	a	a: View Schedule -> http://127.0.0.1:8080/mobile/view-schedule	127.0.0.1	2025-05-18 12:44:22.003246
12944	rossfreedman@gmail.com	click	/mobile/myteam	page_visit	page_visit: Rally -> /mobile/myteam	127.0.0.1	2025-05-18 12:44:26.269925
12964	rossfreedman@gmail.com	static_asset	favicon	\N	Accessed static asset: favicon.ico	127.0.0.1	2025-05-18 12:52:23.812583
12987	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	127.0.0.1	2025-05-18 12:52:33.934966
13008	rossfreedman@gmail.com	click	/mobile/find-subs	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 12:52:50.352637
13028	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:57:06.607072
13049	rossfreedman@gmail.com	click	/mobile/improve	page_visit	page_visit: Rally -> /mobile/improve	127.0.0.1	2025-05-18 12:58:32.922463
13071	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 13:01:59.388947
13091	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:04:31.814826
13112	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 13:07:41.325365
13132	rossfreedman@gmail.com	click	/mobile/availability	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 13:09:56.098758
13153	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:14:18.490018
13173	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:17:00.556776
13193	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 13:22:25.870652
13213	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 13:28:55.021119
13235	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:32:28.162662
13255	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 13:33:57.768221
13275	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:35:11.23647
13276	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:35:11.236447
13296	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:35:20.934053
13316	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:35:40.564083
13336	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:37:53.754503
13357	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: False	127.0.0.1	2025-05-18 13:38:23.564461
13378	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:38:34.327304
13398	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:39:02.136143
13419	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 13:46:59.776425
13439	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:47:46.032504
13459	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:47:57.910893
13480	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:48:15.275695
13479	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:48:15.275703
13502	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:48:32.82609
13522	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:50:52.428711
13543	rossfreedman@gmail.com	click	/mobile	a	a: Create Lineup -> http://127.0.0.1:8080/mobile/lineup	127.0.0.1	2025-05-18 13:51:01.205765
13564	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:52:19.135653
13585	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:54:24.04845
13605	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:54:59.376474
13625	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:55:09.345755
13647	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:56:27.220387
13666	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:59:00.308436
13686	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 14:01:36.391171
13710	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:03:51.780672
13727	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:05:05.505896
13739	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:06:14.67498
13748	rossfreedman@gmail.com	click	/mobile/myteam	page_visit	page_visit: Rally -> /mobile/myteam	127.0.0.1	2025-05-18 14:06:16.298932
12592	rossfreedman@gmail.com	auth	\N	login	Successful login	127.0.0.1	2025-05-18 12:28:59.065739
12612	rossfreedman@gmail.com	auth	\N	login	Successful login	127.0.0.1	2025-05-18 12:30:08.568772
12632	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:31:48.247046
12653	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:35:11.694389
12675	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:15.112057
12694	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:26.243647
12716	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:46.721333
12737	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:05.351001
12757	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:15.462216
12778	rossfreedman@gmail.com	click	/mobile	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 12:37:38.928571
12779	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:37:38.928061
12800	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:37:40.830872
12819	rossfreedman@gmail.com	click	/mobile/myteam	page_visit	page_visit: Rally -> /mobile/myteam	127.0.0.1	2025-05-18 12:38:33.366729
12840	rossfreedman@gmail.com	click	/mobile/analyze-me	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 12:38:39.435629
12862	rossfreedman@gmail.com	click	/mobile	a	a: Improve my game -> http://127.0.0.1:8080/mobile/improve	127.0.0.1	2025-05-18 12:38:56.604953
12882	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:42:08.082939
12904	rossfreedman@gmail.com	click	/mobile/ask-ai	page_visit	page_visit: Rally -> /mobile/ask-ai	127.0.0.1	2025-05-18 12:42:11.768171
12924	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:44:22.025059
12945	rossfreedman@gmail.com	click	/mobile/myteam	page_visit	page_visit: Rally -> /mobile/myteam	127.0.0.1	2025-05-18 12:44:26.274126
12965	rossfreedman@gmail.com	click	/mobile	a	a: Improve my game -> http://127.0.0.1:8080/mobile/improve	127.0.0.1	2025-05-18 12:52:25.778816
12966	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-18 12:52:25.778839
12988	rossfreedman@gmail.com	click	/mobile/my-series	page_visit	page_visit: Rally -> /mobile/my-series	127.0.0.1	2025-05-18 12:52:34.013581
13009	rossfreedman@gmail.com	click	/mobile	a	a: Create Lineup -> http://127.0.0.1:8080/mobile/lineup	127.0.0.1	2025-05-18 12:52:51.367813
13030	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:57:06.610684
13050	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-18 12:59:46.886988
13072	rossfreedman@gmail.com	click	/mobile/view-schedule	page_visit	page_visit: Rally -> /mobile/view-schedule	127.0.0.1	2025-05-18 13:01:59.476775
13092	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:04:31.818953
13114	rossfreedman@gmail.com	click	/mobile/view-schedule	page_visit	page_visit: Rally -> /mobile/view-schedule	127.0.0.1	2025-05-18 13:07:41.411198
13133	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:09:56.173645
13154	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 13:14:19.458762
13174	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:18:12.915016
13194	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:22:25.874138
13214	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:28:55.025481
13237	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:33:51.531812
13256	rossfreedman@gmail.com	click	/mobile/view-schedule	page_visit	page_visit: Rally -> /mobile/view-schedule	127.0.0.1	2025-05-18 13:33:57.855026
13277	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:35:11.240567
13297	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:35:21.740346
13317	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:35:40.564039
13337	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:37:53.762279
13358	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:38:25.395928
13379	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:38:34.484683
13399	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:39:02.136212
13420	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:46:59.779941
13440	rossfreedman@gmail.com	click	/mobile/availability	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 13:47:46.037954
13460	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:47:57.910858
13481	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:48:15.278306
13503	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:48:32.826083
13524	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:50:54.164553
13544	rossfreedman@gmail.com	click	/mobile/lineup	page_visit	page_visit: Rally -> /mobile/lineup	127.0.0.1	2025-05-18 13:51:01.279281
13565	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:52:19.135665
13586	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:54:24.123849
13606	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:54:59.383053
13626	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:56:17.953842
13646	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:56:27.220418
13667	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:59:00.311716
13688	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:01:36.447584
13689	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:01:36.447544
13711	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:03:51.780837
13728	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:05:05.505825
12593	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:28:59.082925
12613	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:30:08.581511
12633	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:31:48.274348
12654	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:35:11.703297
12674	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:15.11178
12695	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:26.248079
12717	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:36:57.097886
12738	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:07.483994
12758	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:15.463587
12780	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:37:38.930024
12801	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:37:40.833754
12821	rossfreedman@gmail.com	click	/mobile/myteam	page_visit	page_visit: Rally -> /mobile/myteam	127.0.0.1	2025-05-18 12:38:33.377774
12842	rossfreedman@gmail.com	click	/mobile	a	a: My Club -> http://127.0.0.1:8080/mobile/my-club	127.0.0.1	2025-05-18 12:38:40.351256
12863	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-18 12:38:56.605973
12884	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:42:08.635036
12905	rossfreedman@gmail.com	click	/mobile/ask-ai	page_visit	page_visit: Rally -> /mobile/ask-ai	127.0.0.1	2025-05-18 12:42:11.767906
12925	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:44:22.088777
12946	rossfreedman@gmail.com	click	/mobile/myteam	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 12:44:27.107136
12967	rossfreedman@gmail.com	click	/mobile/improve	page_visit	page_visit: Rally -> /mobile/improve	127.0.0.1	2025-05-18 12:52:25.867807
12989	rossfreedman@gmail.com	click	/mobile/my-series	page_visit	page_visit: Rally -> /mobile/my-series	127.0.0.1	2025-05-18 12:52:34.01506
13010	rossfreedman@gmail.com	page_visit	mobile_lineup	\N	\N	127.0.0.1	2025-05-18 12:52:51.367745
13031	rossfreedman@gmail.com	click	/mobile	a	a: View Schedule -> http://127.0.0.1:8080/mobile/view-schedule	127.0.0.1	2025-05-18 12:57:07.304132
13053	rossfreedman@gmail.com	click	/mobile/improve	page_visit	page_visit: Rally -> /mobile/improve	127.0.0.1	2025-05-18 12:59:46.972117
13051	rossfreedman@gmail.com	click	/mobile/improve	page_visit	page_visit: Rally -> /mobile/improve	127.0.0.1	2025-05-18 12:59:46.972119
13073	rossfreedman@gmail.com	click	/mobile/view-schedule	page_visit	page_visit: Rally -> /mobile/view-schedule	127.0.0.1	2025-05-18 13:01:59.476692
13093	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 13:04:34.98885
13113	rossfreedman@gmail.com	click	/mobile/view-schedule	page_visit	page_visit: Rally -> /mobile/view-schedule	127.0.0.1	2025-05-18 13:07:41.410479
13134	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:09:56.173557
13155	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:14:19.464185
13176	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:18:12.921261
13195	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:23:34.444943
13215	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:29:47.71688
13216	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:29:47.716989
13236	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:33:51.531522
13257	rossfreedman@gmail.com	click	/mobile/view-schedule	page_visit	page_visit: Rally -> /mobile/view-schedule	127.0.0.1	2025-05-18 13:33:57.855029
13278	rossfreedman@gmail.com	click	/mobile	a	a: View Schedule -> http://127.0.0.1:8080/mobile/view-schedule	127.0.0.1	2025-05-18 13:35:12.213428
13298	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:35:21.911448
13318	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:35:40.564109
13338	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:37:54.383664
13359	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 10/08/2024, Available: False	127.0.0.1	2025-05-18 13:38:25.402098
13380	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:38:34.484677
13400	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:39:02.141659
13421	rossfreedman@gmail.com	click	/mobile/availability	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 13:47:13.875327
13441	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:47:46.103218
13461	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:48:02.183352
13482	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:48:15.991387
13504	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:48:32.829874
13525	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 13:50:54.174532
13545	rossfreedman@gmail.com	click	/mobile/lineup	page_visit	page_visit: Rally -> /mobile/lineup	127.0.0.1	2025-05-18 13:51:01.285145
13566	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:52:19.139176
13587	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:54:24.123805
13607	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:55:01.226454
13627	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:56:17.953849
13648	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:56:27.225405
13668	rossfreedman@gmail.com	static_asset	com.chrome.devtools	\N	Accessed static asset: .well-known/appspecific/com.chrome.devtools.json	127.0.0.1	2025-05-18 13:59:24.98425
13690	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:01:36.45163
13712	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:03:51.78359
12594	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:28:59.184261
12614	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:30:08.667542
12634	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:31:48.333136
12655	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:35:11.724721
12676	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:15.113883
12696	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:27.386971
12719	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-18 12:36:57.099794
12739	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:37:08.64381
12759	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:18.324629
12781	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:37:39.013271
12802	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:37:41.202467
12822	rossfreedman@gmail.com	click	/mobile/myteam	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 12:38:34.622913
12841	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:38:40.350962
12864	rossfreedman@gmail.com	click	/mobile/improve	page_visit	page_visit: Rally -> /mobile/improve	127.0.0.1	2025-05-18 12:38:56.67275
12885	rossfreedman@gmail.com	click	/mobile	a	a: View Schedule -> http://127.0.0.1:8080/mobile/view-schedule	127.0.0.1	2025-05-18 12:42:08.650483
12906	rossfreedman@gmail.com	click	/mobile/ask-ai	page_visit	page_visit: Rally -> /mobile/ask-ai	127.0.0.1	2025-05-18 12:42:11.771383
12926	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:44:22.088732
12947	rossfreedman@gmail.com	click	/mobile	a	a: Me -> http://127.0.0.1:8080/mobile/analyze-me	127.0.0.1	2025-05-18 12:44:28.16712
12968	rossfreedman@gmail.com	click	/mobile/improve	page_visit	page_visit: Rally -> /mobile/improve	127.0.0.1	2025-05-18 12:52:25.869108
12990	rossfreedman@gmail.com	click	/mobile/my-series	page_visit	page_visit: Rally -> /mobile/my-series	127.0.0.1	2025-05-18 12:52:34.019058
13011	rossfreedman@gmail.com	click	/mobile/lineup	page_visit	page_visit: Rally -> /mobile/lineup	127.0.0.1	2025-05-18 12:52:51.439524
13032	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:57:07.306279
13052	rossfreedman@gmail.com	click	/mobile/improve	page_visit	page_visit: Rally -> /mobile/improve	127.0.0.1	2025-05-18 12:59:46.972078
13074	rossfreedman@gmail.com	click	/mobile/view-schedule	page_visit	page_visit: Rally -> /mobile/view-schedule	127.0.0.1	2025-05-18 13:01:59.480283
13094	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:04:35.003003
13115	rossfreedman@gmail.com	click	/mobile/view-schedule	page_visit	page_visit: Rally -> /mobile/view-schedule	127.0.0.1	2025-05-18 13:07:41.413818
13135	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:09:56.177743
13156	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:15:48.307815
13175	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:18:12.921146
13196	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:23:34.44507
13217	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:29:47.720526
13238	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:33:51.538262
13258	rossfreedman@gmail.com	click	/mobile/view-schedule	page_visit	page_visit: Rally -> /mobile/view-schedule	127.0.0.1	2025-05-18 13:33:57.858844
13279	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 13:35:12.219779
13299	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:35:21.911423
13319	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:35:41.475168
13339	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: False	127.0.0.1	2025-05-18 13:37:54.391246
13361	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:38:28.130588
13381	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:38:34.486659
13401	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:39:04.398783
13422	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:47:13.875333
13442	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:47:46.102795
13462	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 10/01/2024, Available: False	127.0.0.1	2025-05-18 13:48:02.193145
13483	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:48:16.150753
13506	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:48:33.281423
13526	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:50:54.870222
13546	rossfreedman@gmail.com	click	/mobile/lineup	page_visit	page_visit: Rally -> /mobile/lineup	127.0.0.1	2025-05-18 13:51:01.289318
13567	rossfreedman@gmail.com	click	/mobile	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 13:52:19.400299
13588	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:54:24.125195
13608	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:55:01.42657
13628	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:56:17.958854
13649	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:58:49.58916
13670	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 14:01:30.710108
13691	rossfreedman@gmail.com	static_asset	com.chrome.devtools	\N	Accessed static asset: .well-known/appspecific/com.chrome.devtools.json	127.0.0.1	2025-05-18 14:01:44.418287
13713	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 14:05:00.79782
13729	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:05:05.509338
13740	rossfreedman@gmail.com	click	/mobile	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 14:06:14.848885
13749	rossfreedman@gmail.com	click	/mobile/myteam	button	button: 	127.0.0.1	2025-05-18 14:06:17.438858
12595	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:29:00.276398
12615	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:30:09.544629
12635	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:33:55.013301
12656	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:35:12.370341
12677	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:16.680592
12697	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:29.94836
12718	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:57.099855
12740	rossfreedman@gmail.com	page_visit	mobile_lineup_escrow	\N	Accessed mobile lineup escrow page	127.0.0.1	2025-05-18 12:37:08.646097
12760	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:18.324819
12782	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:37:39.013273
12803	rossfreedman@gmail.com	click	/mobile	a	a: View Schedule -> http://127.0.0.1:8080/mobile/view-schedule	127.0.0.1	2025-05-18 12:37:41.220786
12823	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:38:34.632394
12843	rossfreedman@gmail.com	click	/mobile/my-club	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 12:38:45.814944
12865	rossfreedman@gmail.com	click	/mobile/improve	page_visit	page_visit: Rally -> /mobile/improve	127.0.0.1	2025-05-18 12:38:56.67275
12886	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:42:08.65819
12907	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:42:13.255151
12927	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:44:22.091735
12948	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-18 12:44:28.193759
12969	rossfreedman@gmail.com	click	/mobile/improve	page_visit	page_visit: Rally -> /mobile/improve	127.0.0.1	2025-05-18 12:52:25.870053
12991	rossfreedman@gmail.com	click	/mobile/my-series	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 12:52:34.967108
13012	rossfreedman@gmail.com	click	/mobile/lineup	page_visit	page_visit: Rally -> /mobile/lineup	127.0.0.1	2025-05-18 12:52:51.439442
13033	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:57:07.317997
13054	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:59:47.867088
13075	rossfreedman@gmail.com	click	/mobile/view-schedule	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 13:02:02.88966
13095	rossfreedman@gmail.com	static_asset	com.chrome.devtools	\N	Accessed static asset: .well-known/appspecific/com.chrome.devtools.json	127.0.0.1	2025-05-18 13:05:07.969211
13116	rossfreedman@gmail.com	click	/mobile/view-schedule	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 13:07:42.873435
13137	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:09:56.562401
13136	rossfreedman@gmail.com	click	/mobile	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 13:09:56.562398
13157	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:15:48.422601
13177	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 13:18:13.787505
13197	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:23:34.448252
13218	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 13:29:48.551127
13239	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 13:33:52.452187
13259	rossfreedman@gmail.com	click	/mobile/view-schedule	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 13:33:59.30815
13281	rossfreedman@gmail.com	click	/mobile/view-schedule	page_visit	page_visit: Rally -> /mobile/view-schedule	127.0.0.1	2025-05-18 13:35:12.304143
13300	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:35:21.914619
13320	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:35:41.649283
13340	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:37:56.375119
13360	rossfreedman@gmail.com	click	/mobile/availability	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 13:38:28.130656
13382	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:38:49.331812
13402	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:39:04.566137
13424	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:47:13.935886
13443	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:47:46.106147
13463	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:48:05.61896
13484	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:48:16.150741
13505	rossfreedman@gmail.com	click	/mobile	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 13:48:33.281551
13527	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 10/01/2024, Available: True	127.0.0.1	2025-05-18 13:50:54.880102
13547	rossfreedman@gmail.com	click	/mobile/lineup	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 13:51:02.281429
13568	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:52:19.400354
13589	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:54:25.465941
13609	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:55:01.42701
13629	rossfreedman@gmail.com	click	/mobile/availability	button	button: 	127.0.0.1	2025-05-18 13:56:19.049741
13651	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:58:49.663051
13669	rossfreedman@gmail.com	click	/mobile	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 14:01:30.71009
13692	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 14:03:44.094075
13714	rossfreedman@gmail.com	click	/mobile	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 14:05:00.801614
13730	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 14:06:14.272652
13741	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 14:06:14.848908
13752	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 14:06:18.807334
13784	rossfreedman@gmail.com	auth	\N	logout	\N	127.0.0.1	2025-05-18 14:12:12.883826
12596	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:29:00.285173
12616	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:30:09.548892
12636	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:33:55.077232
12657	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:35:12.372342
12678	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:36:17.532751
12698	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:30.401456
12721	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:57.171943
12741	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:08.646601
12761	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:18.326062
12783	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:37:39.017823
12804	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:37:41.22606
12824	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:38:34.71142
12844	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:38:49.355835
12866	rossfreedman@gmail.com	click	/mobile/improve	page_visit	page_visit: Rally -> /mobile/improve	127.0.0.1	2025-05-18 12:38:56.675426
12887	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:42:08.680754
12909	rossfreedman@gmail.com	click	/mobile	a	a: Improve my game -> http://127.0.0.1:8080/mobile/improve	127.0.0.1	2025-05-18 12:42:13.259544
12928	rossfreedman@gmail.com	click	/mobile	a	a: View Schedule -> http://127.0.0.1:8080/mobile/view-schedule	127.0.0.1	2025-05-18 12:44:22.727685
12949	rossfreedman@gmail.com	click	/mobile/analyze-me	page_visit	page_visit: Rally -> /mobile/analyze-me	127.0.0.1	2025-05-18 12:44:28.268997
12970	rossfreedman@gmail.com	click	/mobile	a	a: Ask Rally AI -> http://127.0.0.1:8080/mobile/ask-ai	127.0.0.1	2025-05-18 12:52:27.931593
12971	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	Accessed Ask AI page	127.0.0.1	2025-05-18 12:52:27.931544
12992	rossfreedman@gmail.com	click	/mobile	a	a: My Club -> http://127.0.0.1:8080/mobile/my-club	127.0.0.1	2025-05-18 12:52:35.569459
13013	rossfreedman@gmail.com	click	/mobile/lineup	page_visit	page_visit: Rally -> /mobile/lineup	127.0.0.1	2025-05-18 12:52:51.44744
13034	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:57:07.371761
13055	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:59:47.937909
13056	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:59:47.937787
13076	rossfreedman@gmail.com	click	/mobile	a	a: View Schedule -> http://127.0.0.1:8080/mobile/view-schedule	127.0.0.1	2025-05-18 13:02:03.849056
13096	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:06:21.086168
13117	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:07:43.499798
13138	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:09:56.632702
13158	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:15:48.422585
13178	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:18:13.78917
13198	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 13:23:35.475861
13219	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:29:48.560778
13240	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:33:52.458206
13260	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:33:59.854106
13280	rossfreedman@gmail.com	click	/mobile/view-schedule	page_visit	page_visit: Rally -> /mobile/view-schedule	127.0.0.1	2025-05-18 13:35:12.304236
13301	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:35:25.191709
13321	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:35:41.649248
13341	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 10/08/2024, Available: False	127.0.0.1	2025-05-18 13:37:56.3808
13362	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:38:28.202744
13383	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: False	127.0.0.1	2025-05-18 13:38:49.341237
13403	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:39:04.566155
13423	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:47:13.935851
13444	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:47:47.298292
13464	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 10/08/2024, Available: False	127.0.0.1	2025-05-18 13:48:05.628393
13485	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:48:16.157218
13507	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:48:33.333508
13528	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:50:55.360871
13548	rossfreedman@gmail.com	click	/mobile	button	button: 	127.0.0.1	2025-05-18 13:51:03.164402
13570	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:52:19.485174
13591	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:54:25.643419
13610	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:55:01.42756
13630	rossfreedman@gmail.com	click	/mobile/availability	a	a: Logout -> http://127.0.0.1:8080/mobile/availability#	127.0.0.1	2025-05-18 13:56:20.487644
13650	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:58:49.66307
13672	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:01:30.815615
13693	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:03:44.165884
13715	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:05:00.880906
13731	rossfreedman@gmail.com	click	/mobile	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 14:06:14.273791
12597	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:29:00.309828
12617	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:30:09.569386
12637	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:33:55.722275
12658	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:35:12.378047
12679	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	127.0.0.1	2025-05-18 12:36:17.535074
12700	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:31.759814
12720	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:57.171973
12742	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:08.718503
12762	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:37:18.975463
12784	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:37:39.53015
12805	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:37:41.23693
12825	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:38:34.711398
12845	rossfreedman@gmail.com	click	/mobile	a	a: My Competition -> http://127.0.0.1:8080/mobile/teams-players	127.0.0.1	2025-05-18 12:38:49.364739
12867	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:38:58.503126
12868	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:38:58.50312
12889	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:42:08.742751
12908	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-18 12:42:13.259046
12929	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:44:22.735855
12950	rossfreedman@gmail.com	click	/mobile/analyze-me	page_visit	page_visit: Rally -> /mobile/analyze-me	127.0.0.1	2025-05-18 12:44:28.269031
12973	rossfreedman@gmail.com	click	/mobile/ask-ai	page_visit	page_visit: Rally -> /mobile/ask-ai	127.0.0.1	2025-05-18 12:52:27.995914
12993	rossfreedman@gmail.com	click	/mobile/my-club	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 12:52:36.513276
13014	rossfreedman@gmail.com	click	/mobile/lineup	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 12:52:53.299112
13035	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:57:07.371753
13057	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:59:47.940536
13077	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 13:02:03.852016
13097	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:06:21.086173
13118	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:07:43.659516
13140	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:09:56.634432
13159	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:15:48.426584
13179	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:19:43.361726
13199	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:23:35.483775
13220	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:30:55.916188
13221	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:30:55.916155
13241	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: False	127.0.0.1	2025-05-18 13:33:53.40108
13261	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:34:00.01316
13282	rossfreedman@gmail.com	click	/mobile/view-schedule	page_visit	page_visit: Rally -> /mobile/view-schedule	127.0.0.1	2025-05-18 13:35:12.308077
13302	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: False	127.0.0.1	2025-05-18 13:35:25.199844
13322	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:35:41.649918
13342	rossfreedman@gmail.com	click	/mobile/availability	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 13:37:59.785029
13363	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:38:28.202573
13384	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:38:50.180227
13404	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:39:04.571309
13425	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:47:13.940458
13445	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:47:47.46797
13465	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:48:06.645489
13486	rossfreedman@gmail.com	click	/mobile/availability	button	button: 	127.0.0.1	2025-05-18 13:48:25.678522
13508	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:48:33.334107
13529	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: False	127.0.0.1	2025-05-18 13:50:55.372463
13549	rossfreedman@gmail.com	auth	\N	logout	\N	127.0.0.1	2025-05-18 13:51:04.742733
13569	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:52:19.485206
13590	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:54:25.643365
13611	rossfreedman@gmail.com	click	/mobile/availability	button	button: 	127.0.0.1	2025-05-18 13:55:01.970803
13632	rossfreedman@gmail.com	auth	\N	logout	\N	127.0.0.1	2025-05-18 13:56:20.489469
13652	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:58:49.664835
13671	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:01:30.815636
13694	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:03:44.165914
13716	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:05:00.88088
13733	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:06:14.337333
13742	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:06:14.90673
12598	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:29:00.371258
12618	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:30:09.628701
12638	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:33:55.798607
12659	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:35:12.38881
12680	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:17.539259
12699	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:36:31.759825
12722	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:57.176351
12743	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:08.718453
12763	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:19.033497
12785	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:37:39.877036
12807	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:37:41.297325
12826	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:38:34.71709
12846	rossfreedman@gmail.com	click	/mobile/teams-players	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 12:38:50.81964
12869	rossfreedman@gmail.com	click	/mobile/improve	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 12:38:58.504344
12888	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:42:08.742742
12911	rossfreedman@gmail.com	click	/mobile/improve	page_visit	page_visit: Rally -> /mobile/improve	127.0.0.1	2025-05-18 12:42:13.331813
12930	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:44:22.746537
12951	rossfreedman@gmail.com	click	/mobile/analyze-me	page_visit	page_visit: Rally -> /mobile/analyze-me	127.0.0.1	2025-05-18 12:44:28.272226
12972	rossfreedman@gmail.com	click	/mobile/ask-ai	page_visit	page_visit: Rally -> /mobile/ask-ai	127.0.0.1	2025-05-18 12:52:27.995927
12994	rossfreedman@gmail.com	click	/mobile	a	a: My Competition -> http://127.0.0.1:8080/mobile/teams-players	127.0.0.1	2025-05-18 12:52:37.383698
13015	rossfreedman@gmail.com	click	/mobile	a	a: Lineup Escrow -> http://127.0.0.1:8080/mobile/lineup-escrow	127.0.0.1	2025-05-18 12:52:54.105853
13036	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:57:07.375508
13058	rossfreedman@gmail.com	click	/mobile	a	a: View Schedule -> http://127.0.0.1:8080/mobile/view-schedule	127.0.0.1	2025-05-18 12:59:48.778882
13078	rossfreedman@gmail.com	click	/mobile/view-schedule	page_visit	page_visit: Rally -> /mobile/view-schedule	127.0.0.1	2025-05-18 13:02:03.925545
13098	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:06:21.090583
13119	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:07:43.661325
13139	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:09:56.634363
13160	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:15:49.335302
13180	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:19:43.361747
13200	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:26:37.491595
13222	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:30:55.920713
13242	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:33:53.407129
13262	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:34:00.016217
13283	rossfreedman@gmail.com	click	/mobile/view-schedule	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 13:35:13.59005
13303	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:35:26.964589
13323	rossfreedman@gmail.com	click	/mobile/availability	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 13:36:43.758216
13343	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:38:00.6641
13364	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:38:28.205558
13385	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 10/01/2024, Available: False	127.0.0.1	2025-05-18 13:38:50.188757
13405	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:39:16.492039
13426	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:47:14.548308
13446	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:47:47.46796
13466	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 10/15/2024, Available: False	127.0.0.1	2025-05-18 13:48:06.658376
13488	rossfreedman@gmail.com	auth	\N	logout	\N	127.0.0.1	2025-05-18 13:48:27.964477
13509	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:48:33.33654
13530	rossfreedman@gmail.com	click	/mobile/availability	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 13:50:56.31648
13550	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 13:51:04.742701
13571	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:52:19.489316
13592	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:54:25.646924
13612	rossfreedman@gmail.com	click	/mobile/availability	button	button: 	127.0.0.1	2025-05-18 13:55:02.568852
13631	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:56:20.489509
13653	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:58:52.834329
13673	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:01:30.818274
13695	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:03:44.171373
13717	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:05:00.886143
13732	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:06:14.337263
13743	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:06:14.907134
13750	rossfreedman@gmail.com	click	/mobile/myteam	a	a: Logout -> http://127.0.0.1:8080/mobile/myteam#	127.0.0.1	2025-05-18 14:06:18.807414
12599	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:29:01.903372
12619	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:30:28.079768
12639	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:33:56.263627
12661	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:35:12.813423
12660	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:35:12.81355
12682	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:17.607438
12701	rossfreedman@gmail.com	static_asset	favicon	\N	Accessed static asset: favicon.ico	127.0.0.1	2025-05-18 12:36:31.791605
12723	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:59.244083
12744	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:08.722828
12764	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:19.033367
12786	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:37:39.879419
12806	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:37:41.297283
12827	rossfreedman@gmail.com	click	/mobile	a	a: My Series -> http://127.0.0.1:8080/mobile/myseries	127.0.0.1	2025-05-18 12:38:35.501317
12847	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:38:51.820914
12870	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:38:58.574967
12890	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:42:08.746175
12910	rossfreedman@gmail.com	click	/mobile/improve	page_visit	page_visit: Rally -> /mobile/improve	127.0.0.1	2025-05-18 12:42:13.331808
12931	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:44:22.816502
12932	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:44:22.816568
12952	rossfreedman@gmail.com	click	/mobile/analyze-me	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 12:44:29.255104
12974	rossfreedman@gmail.com	click	/mobile/ask-ai	page_visit	page_visit: Rally -> /mobile/ask-ai	127.0.0.1	2025-05-18 12:52:27.998398
12995	rossfreedman@gmail.com	click	/mobile/teams-players	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 12:52:39.805813
13016	rossfreedman@gmail.com	page_visit	mobile_lineup_escrow	\N	Accessed mobile lineup escrow page	127.0.0.1	2025-05-18 12:52:54.10891
13037	rossfreedman@gmail.com	static_asset	com.chrome.devtools	\N	Accessed static asset: .well-known/appspecific/com.chrome.devtools.json	127.0.0.1	2025-05-18 12:57:19.767958
13059	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:59:48.783062
13079	rossfreedman@gmail.com	click	/mobile/view-schedule	page_visit	page_visit: Rally -> /mobile/view-schedule	127.0.0.1	2025-05-18 13:02:03.925577
13099	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 13:06:22.408475
13120	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:07:43.662399
13141	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:09:57.217389
13162	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:15:49.502312
13181	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:19:43.365856
13201	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:26:37.491807
13223	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:30:56.599383
13243	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:33:54.278641
13263	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:34:00.017263
13284	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:35:14.387294
13304	rossfreedman@gmail.com	click	/mobile/availability	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 13:35:26.966807
13324	rossfreedman@gmail.com	click	/mobile	a	a: View Schedule -> http://127.0.0.1:8080/mobile/view-schedule	127.0.0.1	2025-05-18 13:36:44.38017
13344	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:38:00.837296
13365	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:38:29.418745
13386	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:38:51.349298
13406	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: False	127.0.0.1	2025-05-18 13:39:16.501271
13428	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:47:14.707409
13447	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:47:47.472973
13467	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:48:07.088349
13487	rossfreedman@gmail.com	click	/mobile/availability	a	a: Logout -> http://127.0.0.1:8080/mobile/availability#	127.0.0.1	2025-05-18 13:48:27.96425
13510	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:50:49.706464
13531	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:50:56.995705
13551	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:51:04.744522
13572	rossfreedman@gmail.com	click	/mobile	a	a: Ask Rally AI -> http://127.0.0.1:8080/mobile/ask-ai	127.0.0.1	2025-05-18 13:52:20.135849
13573	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	Accessed Ask AI page	127.0.0.1	2025-05-18 13:52:20.136066
13593	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:54:26.395977
13613	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:55:03.42046
13633	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:56:20.571639
13654	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:58:53.047204
13674	rossfreedman@gmail.com	click	/mobile	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 14:01:31.104192
13675	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 14:01:31.104253
12601	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-18 12:29:03.726184
12620	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:30:28.087428
12640	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:33:56.276412
12662	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:35:12.823115
12681	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:17.607408
12702	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:36:33.598826
12724	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:37:00.095402
12745	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:09.900958
12765	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:19.0359
12787	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:37:39.879372
12808	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:37:41.301206
12828	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:38:35.501351
12848	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:38:51.844316
12871	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:38:58.574765
12891	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:42:09.474799
12912	rossfreedman@gmail.com	click	/mobile/improve	page_visit	page_visit: Rally -> /mobile/improve	127.0.0.1	2025-05-18 12:42:13.3343
12933	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:44:22.819988
12953	rossfreedman@gmail.com	click	/mobile	a	a: My Series -> http://127.0.0.1:8080/mobile/myseries	127.0.0.1	2025-05-18 12:44:29.859256
12975	rossfreedman@gmail.com	click	/mobile	a	a: Me -> http://127.0.0.1:8080/mobile/analyze-me	127.0.0.1	2025-05-18 12:52:30.576008
12996	rossfreedman@gmail.com	click	/mobile/teams-players	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 12:52:40.965175
13018	rossfreedman@gmail.com	click	/mobile/lineup-escrow	page_visit	page_visit: Lineup Escrow™ | Rally -> /mobile/lineup-escrow	127.0.0.1	2025-05-18 12:52:54.165078
13017	rossfreedman@gmail.com	click	/mobile/lineup-escrow	page_visit	page_visit: Lineup Escrow™ | Rally -> /mobile/lineup-escrow	127.0.0.1	2025-05-18 12:52:54.165088
13038	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-18 12:58:27.314319
13060	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:59:48.813812
13080	rossfreedman@gmail.com	click	/mobile/view-schedule	page_visit	page_visit: Rally -> /mobile/view-schedule	127.0.0.1	2025-05-18 13:02:03.927446
13100	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:06:22.413516
13121	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 13:07:44.602861
13142	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:09:57.375219
13161	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:15:49.501895
13182	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 13:19:44.319947
13202	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:26:37.493847
13224	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:30:56.599496
13244	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 13:33:54.284663
13264	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 13:34:01.096231
13285	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:35:14.57655
13305	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:35:27.035541
13325	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 13:36:44.38402
13345	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:38:00.837277
13367	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:38:29.590998
13387	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 10/15/2024, Available: True	127.0.0.1	2025-05-18 13:38:51.3629
13408	rossfreedman@gmail.com	click	/mobile/availability	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 13:39:18.953861
13427	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:47:14.707709
13448	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:47:50.317764
13468	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 10/15/2024, Available: True	127.0.0.1	2025-05-18 13:48:07.099028
13489	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:48:27.967079
13511	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:50:49.823576
13532	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:50:57.1521
13552	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:51:04.801585
13574	rossfreedman@gmail.com	click	/mobile/ask-ai	page_visit	page_visit: Rally -> /mobile/ask-ai	127.0.0.1	2025-05-18 13:52:20.207372
13594	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 13:54:26.4063
13614	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: False	127.0.0.1	2025-05-18 13:55:03.429666
13634	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:56:20.573331
13655	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:58:53.047184
13676	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:01:31.177964
13696	rossfreedman@gmail.com	click	/mobile	a	a: View Schedule -> http://127.0.0.1:8080/mobile/view-schedule	127.0.0.1	2025-05-18 14:03:45.167282
13718	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 14:05:01.31362
12600	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:29:03.726148
12621	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:30:28.099899
12641	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:33:56.286122
12663	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:35:12.835494
12683	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:17.60953
12703	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	Accessed Ask AI page	127.0.0.1	2025-05-18 12:36:33.605867
12704	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:33.605824
12725	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:00.108817
12746	rossfreedman@gmail.com	static_asset	reserve-court	\N	Accessed static asset: mobile/reserve-court	127.0.0.1	2025-05-18 12:37:10.900355
12766	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:37:19.465282
12788	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:37:40.137573
12809	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:37:42.086968
12829	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	127.0.0.1	2025-05-18 12:38:35.502701
12849	rossfreedman@gmail.com	click	/mobile	a	a: View Schedule -> http://127.0.0.1:8080/mobile/view-schedule	127.0.0.1	2025-05-18 12:38:51.844249
12872	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:38:58.577982
12892	rossfreedman@gmail.com	click	/mobile	a	a: View Schedule -> http://127.0.0.1:8080/mobile/view-schedule	127.0.0.1	2025-05-18 12:42:09.486489
12893	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:42:09.486423
12913	rossfreedman@gmail.com	static_asset	com.chrome.devtools	\N	Accessed static asset: .well-known/appspecific/com.chrome.devtools.json	127.0.0.1	2025-05-18 12:42:38.222908
12934	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 12:44:23.125475
12954	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	127.0.0.1	2025-05-18 12:44:29.859252
12976	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-18 12:52:30.602464
12997	rossfreedman@gmail.com	click	/mobile	a	a: Team Schedule -> http://127.0.0.1:8080/mobile/view-schedule	127.0.0.1	2025-05-18 12:52:42.52284
13019	rossfreedman@gmail.com	click	/mobile/lineup-escrow	page_visit	page_visit: Lineup Escrow™ | Rally -> /mobile/lineup-escrow	127.0.0.1	2025-05-18 12:52:54.167817
13039	rossfreedman@gmail.com	click	/mobile	a	a: Improve my game -> http://127.0.0.1:8080/mobile/improve	127.0.0.1	2025-05-18 12:58:27.318497
13061	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:59:48.86054
13081	rossfreedman@gmail.com	click	/mobile/view-schedule	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 13:02:04.492337
13101	rossfreedman@gmail.com	click	/mobile/availability	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 13:07:40.265954
13122	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:07:44.606612
13143	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:09:57.375261
13163	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:15:49.504452
13183	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:19:44.322628
13203	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 13:26:38.476895
13225	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:30:56.603684
13245	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:33:54.866689
13265	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:34:01.100006
13286	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:35:14.576496
13306	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:35:27.03555
13327	rossfreedman@gmail.com	click	/mobile/view-schedule	page_visit	page_visit: Rally -> /mobile/view-schedule	127.0.0.1	2025-05-18 13:36:44.472756
13346	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:38:00.842612
13366	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:38:29.591017
13388	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:38:52.174092
13407	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:39:18.9539
13429	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:47:14.711769
13449	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 10/15/2024, Available: True	127.0.0.1	2025-05-18 13:47:50.327688
13469	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:48:08.120063
13491	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:48:28.037342
13490	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:48:28.037377
13512	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:50:49.82386
13533	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:50:57.154024
13553	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:51:04.801565
13575	rossfreedman@gmail.com	click	/mobile/ask-ai	page_visit	page_visit: Rally -> /mobile/ask-ai	127.0.0.1	2025-05-18 13:52:20.207292
13595	rossfreedman@gmail.com	click	/mobile/availability	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 13:54:27.912659
13615	rossfreedman@gmail.com	click	/mobile/availability	button	button: 	127.0.0.1	2025-05-18 13:55:05.703466
13635	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:56:20.573694
13656	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:58:53.052745
13677	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:01:31.180625
13697	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 14:03:45.171213
13751	rossfreedman@gmail.com	auth	\N	logout	\N	127.0.0.1	2025-05-18 14:06:18.807404
12602	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:29:03.799497
12622	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:30:28.158496
12642	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:33:56.307851
12664	rossfreedman@gmail.com	static_asset	com.chrome.devtools	\N	Accessed static asset: .well-known/appspecific/com.chrome.devtools.json	127.0.0.1	2025-05-18 12:35:21.979048
12684	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:18.890072
12706	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:33.670734
12705	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:33.670564
12726	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:37:00.118651
12747	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:10.90113
12767	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:19.520789
12789	rossfreedman@gmail.com	click	/mobile	a	a: View Schedule -> http://127.0.0.1:8080/mobile/view-schedule	127.0.0.1	2025-05-18 12:37:40.144091
12810	rossfreedman@gmail.com	click	/mobile	a	a: View Schedule -> http://127.0.0.1:8080/mobile/view-schedule	127.0.0.1	2025-05-18 12:37:42.086948
12831	rossfreedman@gmail.com	click	/mobile/my-series	page_visit	page_visit: Rally -> /mobile/my-series	127.0.0.1	2025-05-18 12:38:35.594199
12850	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:38:51.855695
12873	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:38:59.175512
12894	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:42:09.498152
12914	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:44:20.66712
12935	rossfreedman@gmail.com	static_asset	favicon	\N	Accessed static asset: favicon.ico	127.0.0.1	2025-05-18 12:44:23.156131
12955	rossfreedman@gmail.com	click	/mobile/my-series	page_visit	page_visit: Rally -> /mobile/my-series	127.0.0.1	2025-05-18 12:44:29.937565
12977	rossfreedman@gmail.com	click	/mobile/analyze-me	page_visit	page_visit: Rally -> /mobile/analyze-me	127.0.0.1	2025-05-18 12:52:30.701683
12998	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:52:42.522876
13020	rossfreedman@gmail.com	click	/mobile/lineup-escrow	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 12:52:54.965805
13041	rossfreedman@gmail.com	click	/mobile/improve	page_visit	page_visit: Rally -> /mobile/improve	127.0.0.1	2025-05-18 12:58:27.389022
13062	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:59:48.860577
13082	rossfreedman@gmail.com	click	/mobile	a	a: Team Schedule -> http://127.0.0.1:8080/mobile/view-schedule	127.0.0.1	2025-05-18 13:02:05.800516
13102	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:07:40.270593
13123	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:09:41.325561
13144	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:09:57.379998
13164	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 13:15:50.300318
13185	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:21:14.436939
13204	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:26:38.481988
13226	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 13:30:57.298545
13246	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: False	127.0.0.1	2025-05-18 13:33:54.874805
13266	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:34:01.904759
13287	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:35:14.580211
13307	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:35:27.038169
13326	rossfreedman@gmail.com	click	/mobile/view-schedule	page_visit	page_visit: Rally -> /mobile/view-schedule	127.0.0.1	2025-05-18 13:36:44.472717
13347	rossfreedman@gmail.com	click	/mobile/availability	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 13:38:21.680423
13348	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:38:21.680373
13368	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:38:29.594794
13389	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 10/08/2024, Available: False	127.0.0.1	2025-05-18 13:38:52.183973
13409	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:39:19.022853
13431	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:47:41.138146
13450	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:47:53.837305
13470	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 10/22/2024, Available: True	127.0.0.1	2025-05-18 13:48:08.121481
13492	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:48:28.042628
13513	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:50:49.829685
13534	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:50:57.155188
13554	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:51:04.805906
13576	rossfreedman@gmail.com	click	/mobile/ask-ai	page_visit	page_visit: Rally -> /mobile/ask-ai	127.0.0.1	2025-05-18 13:52:20.209904
13596	rossfreedman@gmail.com	click	/mobile	button	button: 	127.0.0.1	2025-05-18 13:54:30.654124
13616	rossfreedman@gmail.com	auth	\N	logout	\N	127.0.0.1	2025-05-18 13:55:07.662836
13636	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:56:22.206713
13657	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:58:54.690287
13678	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:01:31.182513
13699	rossfreedman@gmail.com	click	/mobile/view-schedule	page_visit	page_visit: Rally -> /mobile/view-schedule	127.0.0.1	2025-05-18 14:03:45.267383
13698	rossfreedman@gmail.com	click	/mobile/view-schedule	page_visit	page_visit: Rally -> /mobile/view-schedule	127.0.0.1	2025-05-18 14:03:45.26741
13719	rossfreedman@gmail.com	click	/mobile	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 14:05:01.314428
12604	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:29:05.960548
12623	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:31:32.67306
12643	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:33:56.364945
12665	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:36:12.127488
12685	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:36:19.638717
12707	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:33.674122
12727	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:37:00.133506
12748	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:37:10.90117
12768	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-18 12:37:19.54546
12790	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:37:40.144725
12811	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:37:42.094069
12830	rossfreedman@gmail.com	click	/mobile/my-series	page_visit	page_visit: Rally -> /mobile/my-series	127.0.0.1	2025-05-18 12:38:35.594164
12851	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:38:51.911754
12852	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:38:51.911696
12874	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 12:38:59.199392
12895	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:42:09.553337
12915	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:44:21.045779
12936	rossfreedman@gmail.com	click	/mobile	a	a: Me -> http://127.0.0.1:8080/mobile/analyze-me	127.0.0.1	2025-05-18 12:44:24.745869
12956	rossfreedman@gmail.com	click	/mobile/my-series	page_visit	page_visit: Rally -> /mobile/my-series	127.0.0.1	2025-05-18 12:44:29.937599
12978	rossfreedman@gmail.com	click	/mobile/analyze-me	page_visit	page_visit: Rally -> /mobile/analyze-me	127.0.0.1	2025-05-18 12:52:30.70136
12999	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:52:42.548172
13021	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:57:05.518276
13040	rossfreedman@gmail.com	click	/mobile/improve	page_visit	page_visit: Rally -> /mobile/improve	127.0.0.1	2025-05-18 12:58:27.388968
13063	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:59:48.863024
13083	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 13:02:05.805331
13103	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:07:40.338146
13124	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:09:41.325516
13145	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:10:01.095575
13165	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:15:50.304318
13184	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:21:14.436535
13205	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:27:42.425199
13227	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:30:57.306988
13247	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:33:55.455046
13267	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 10/01/2024, Available: True	127.0.0.1	2025-05-18 13:34:01.913976
13288	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:35:15.3576
13308	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:35:28.100293
13328	rossfreedman@gmail.com	click	/mobile/view-schedule	page_visit	page_visit: Rally -> /mobile/view-schedule	127.0.0.1	2025-05-18 13:36:44.477393
13350	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:38:21.755744
13369	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:38:31.845918
13390	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:38:52.756418
13410	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:39:19.023349
13430	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:47:41.138135
13451	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 10/08/2024, Available: True	127.0.0.1	2025-05-18 13:47:53.846958
13471	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:48:09.586268
13493	rossfreedman@gmail.com	click	/mobile	button	button: 	127.0.0.1	2025-05-18 13:48:29.780117
13514	rossfreedman@gmail.com	click	/mobile	a	a: View Schedule -> http://127.0.0.1:8080/mobile/view-schedule	127.0.0.1	2025-05-18 13:50:50.619821
13535	rossfreedman@gmail.com	click	/mobile/availability	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 13:50:57.822128
13555	rossfreedman@gmail.com	click	/mobile	button	button: 	127.0.0.1	2025-05-18 13:51:09.357153
13577	rossfreedman@gmail.com	click	/mobile/ask-ai	button	button: 	127.0.0.1	2025-05-18 13:52:20.817899
13597	rossfreedman@gmail.com	auth	\N	logout	\N	127.0.0.1	2025-05-18 13:54:32.071008
13617	rossfreedman@gmail.com	click	/mobile/availability	a	a: Logout -> http://127.0.0.1:8080/mobile/availability#	127.0.0.1	2025-05-18 13:55:07.663911
13638	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:56:22.374642
13658	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 13:58:54.701161
13679	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 14:01:31.55861
13700	rossfreedman@gmail.com	click	/mobile/view-schedule	page_visit	page_visit: Rally -> /mobile/view-schedule	127.0.0.1	2025-05-18 14:03:45.270105
13720	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:05:01.380836
13734	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:06:14.337282
13744	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:06:14.908569
13754	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:06:18.871735
12603	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	Accessed Ask AI page	127.0.0.1	2025-05-18 12:29:05.960547
12624	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:31:32.742604
12645	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:33:57.065946
12644	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:33:57.065956
12666	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:12.127494
12686	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:19.649299
12708	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:34.439343
12728	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:00.190454
12749	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:37:12.906131
12770	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:19.619947
12791	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:37:40.166289
12812	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:37:42.106546
12832	rossfreedman@gmail.com	click	/mobile/my-series	page_visit	page_visit: Rally -> /mobile/my-series	127.0.0.1	2025-05-18 12:38:35.596444
12853	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:38:51.914879
12875	rossfreedman@gmail.com	static_asset	favicon	\N	Accessed static asset: favicon.ico	127.0.0.1	2025-05-18 12:38:59.224306
12896	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:42:09.553434
12916	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:44:21.045753
12937	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-18 12:44:24.773176
12957	rossfreedman@gmail.com	click	/mobile/my-series	page_visit	page_visit: Rally -> /mobile/my-series	127.0.0.1	2025-05-18 12:44:29.937882
12979	rossfreedman@gmail.com	click	/mobile/analyze-me	page_visit	page_visit: Rally -> /mobile/analyze-me	127.0.0.1	2025-05-18 12:52:30.703504
13001	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:52:42.605904
13023	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:57:05.590338
13042	rossfreedman@gmail.com	click	/mobile/improve	page_visit	page_visit: Rally -> /mobile/improve	127.0.0.1	2025-05-18 12:58:27.391731
13064	rossfreedman@gmail.com	click	/mobile	a	a: Me -> http://127.0.0.1:8080/mobile/analyze-me	127.0.0.1	2025-05-18 13:01:57.678886
13084	rossfreedman@gmail.com	click	/mobile/view-schedule	page_visit	page_visit: Rally -> /mobile/view-schedule	127.0.0.1	2025-05-18 13:02:05.872641
13104	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:07:40.338604
13125	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:09:41.33051
13146	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:12:03.831171
13167	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:16:59.453966
13186	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:21:14.440501
13206	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:27:42.425169
13228	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:32:26.782411
13248	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 10/01/2024, Available: True	127.0.0.1	2025-05-18 13:33:55.466592
13268	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 10/01/2024, Available: False	127.0.0.1	2025-05-18 13:34:03.96889
13289	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: False	127.0.0.1	2025-05-18 13:35:15.366329
13309	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:35:28.266742
13329	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:37:52.766998
13349	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:38:21.755552
13370	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: False	127.0.0.1	2025-05-18 13:38:31.855943
13391	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 10/15/2024, Available: False	127.0.0.1	2025-05-18 13:38:52.765522
13411	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:39:19.026976
13432	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:47:41.142564
13452	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:47:55.22344
13472	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 10/29/2024, Available: True	127.0.0.1	2025-05-18 13:48:09.595309
13494	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 13:48:31.522893
13495	rossfreedman@gmail.com	auth	\N	logout	\N	127.0.0.1	2025-05-18 13:48:31.522167
13515	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 13:50:50.624022
13536	rossfreedman@gmail.com	click	/mobile	a	a: My Series -> http://127.0.0.1:8080/mobile/myseries	127.0.0.1	2025-05-18 13:50:58.494442
13557	rossfreedman@gmail.com	auth	\N	logout	\N	127.0.0.1	2025-05-18 13:51:12.846477
13556	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 13:51:12.84646
13578	rossfreedman@gmail.com	click	/mobile/ask-ai	a	a: Logout -> http://127.0.0.1:8080/mobile/ask-ai#	127.0.0.1	2025-05-18 13:52:22.148581
13598	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 13:54:32.071043
13618	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:55:07.66459
13637	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:56:22.374615
13659	rossfreedman@gmail.com	click	/mobile/availability	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 13:58:56.018503
13680	rossfreedman@gmail.com	click	/mobile	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 14:01:31.560821
13701	rossfreedman@gmail.com	click	/mobile/view-schedule	button	button: 	127.0.0.1	2025-05-18 14:03:46.963049
13721	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:05:01.380804
13735	rossfreedman@gmail.com	click	/mobile	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 14:06:14.601357
12605	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:29:06.035713
12625	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:31:33.686719
12646	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:33:57.075756
12667	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-18 12:36:12.151226
12687	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:20.822543
12709	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:36:35.084427
12729	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:00.190439
12750	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:12.908121
12769	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:19.619974
12793	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:37:40.223105
12813	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:37:42.163716
12833	rossfreedman@gmail.com	click	/mobile/my-series	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 12:38:36.607015
12855	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	Accessed Ask AI page	127.0.0.1	2025-05-18 12:38:53.359812
12856	rossfreedman@gmail.com	click	/mobile	a	a: Ask Rally AI -> http://127.0.0.1:8080/mobile/ask-ai	127.0.0.1	2025-05-18 12:38:53.359828
12876	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:42:07.439463
12897	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:42:09.556627
12917	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:44:21.050541
12938	rossfreedman@gmail.com	click	/mobile/analyze-me	page_visit	page_visit: Rally -> /mobile/analyze-me	127.0.0.1	2025-05-18 12:44:24.865119
12958	rossfreedman@gmail.com	click	/mobile/my-series	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 12:44:31.075816
12980	rossfreedman@gmail.com	click	/mobile/analyze-me	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 12:52:31.449879
13000	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:52:42.605835
13022	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:57:05.590151
13043	rossfreedman@gmail.com	click	/mobile/improve	button	button: 	127.0.0.1	2025-05-18 12:58:29.115167
13065	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-18 13:01:57.705963
13085	rossfreedman@gmail.com	click	/mobile/view-schedule	page_visit	page_visit: Rally -> /mobile/view-schedule	127.0.0.1	2025-05-18 13:02:05.87271
13105	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:07:40.34044
13126	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:09:43.079448
13147	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:12:03.83157
13166	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:16:59.453936
13187	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 13:21:16.080419
13207	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:27:42.4298
13229	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:32:26.782428
13249	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:33:57.182617
13269	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:34:03.974318
13290	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:35:19.209433
13310	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:35:28.266896
13330	rossfreedman@gmail.com	click	/mobile/view-schedule	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 13:37:52.767624
13351	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:38:21.759048
13371	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:38:32.45554
13392	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:38:53.47317
13412	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:39:19.843752
13433	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 13:47:42.055401
13453	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 10/29/2024, Available: True	127.0.0.1	2025-05-18 13:47:55.232566
13473	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:48:13.08776
13496	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:48:31.52426
13516	rossfreedman@gmail.com	click	/mobile/view-schedule	page_visit	page_visit: Rally -> /mobile/view-schedule	127.0.0.1	2025-05-18 13:50:50.710115
13517	rossfreedman@gmail.com	click	/mobile/view-schedule	page_visit	page_visit: Rally -> /mobile/view-schedule	127.0.0.1	2025-05-18 13:50:50.710156
13537	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	127.0.0.1	2025-05-18 13:50:58.496514
13558	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:51:12.850449
13579	rossfreedman@gmail.com	auth	\N	logout	\N	127.0.0.1	2025-05-18 13:52:22.148537
13599	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:54:32.072297
13619	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:55:07.729682
13639	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:56:22.379783
13660	rossfreedman@gmail.com	click	/mobile	a	a: My Club -> http://127.0.0.1:8080/mobile/my-club	127.0.0.1	2025-05-18 13:58:57.350838
13681	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:01:31.620563
13702	rossfreedman@gmail.com	click	/mobile/view-schedule	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 14:03:48.362503
13722	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:05:01.383731
13736	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 14:06:14.601301
13745	rossfreedman@gmail.com	click	/mobile	a	a: My Team -> http://127.0.0.1:8080/mobile/myteam	127.0.0.1	2025-05-18 14:06:16.219141
13753	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:06:18.870961
12606	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:29:07.907427
12626	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:31:33.750548
12647	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:33:57.091231
12668	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:12.272727
12688	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:36:21.663289
12710	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:35.090611
12730	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:00.19525
12751	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:14.492594
12771	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:19.624122
12792	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:37:40.222935
12814	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:37:42.163639
12834	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:38:37.289584
12854	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:38:53.359764
12877	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:42:07.760857
12898	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:42:10.23122
12918	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:44:21.333429
12939	rossfreedman@gmail.com	click	/mobile/analyze-me	page_visit	page_visit: Rally -> /mobile/analyze-me	127.0.0.1	2025-05-18 12:44:24.865071
12959	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:52:13.592935
12981	rossfreedman@gmail.com	click	/mobile	a	a: My Team -> http://127.0.0.1:8080/mobile/myteam	127.0.0.1	2025-05-18 12:52:32.242094
13002	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:52:42.609216
13024	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:57:05.59338
13044	rossfreedman@gmail.com	click	/mobile/improve	button	button: 	127.0.0.1	2025-05-18 12:58:31.073177
13066	rossfreedman@gmail.com	click	/mobile/analyze-me	page_visit	page_visit: Rally -> /mobile/analyze-me	127.0.0.1	2025-05-18 13:01:57.79586
13086	rossfreedman@gmail.com	click	/mobile/view-schedule	page_visit	page_visit: Rally -> /mobile/view-schedule	127.0.0.1	2025-05-18 13:02:05.875532
13106	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:07:40.89016
13107	rossfreedman@gmail.com	click	/mobile	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 13:07:40.890184
13127	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:09:45.746165
13148	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:12:03.83555
13168	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:16:59.459062
13188	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:21:16.084622
13208	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 13:27:43.446795
13230	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:32:26.785934
13250	rossfreedman@gmail.com	click	/mobile/availability	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 13:33:57.183958
13270	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:34:05.690194
13291	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 10/08/2024, Available: False	127.0.0.1	2025-05-18 13:35:19.218592
13311	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:35:28.270779
13331	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:37:52.83993
13352	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:38:22.635794
13372	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 10/01/2024, Available: False	127.0.0.1	2025-05-18 13:38:32.465081
13393	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 10/22/2024, Available: False	127.0.0.1	2025-05-18 13:38:53.48002
13414	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:39:20.018371
13434	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:47:42.059194
13454	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:47:55.608472
13474	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 11/12/2024, Available: True	127.0.0.1	2025-05-18 13:48:13.097195
13497	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:48:31.580091
13518	rossfreedman@gmail.com	click	/mobile/view-schedule	page_visit	page_visit: Rally -> /mobile/view-schedule	127.0.0.1	2025-05-18 13:50:50.712666
13538	rossfreedman@gmail.com	click	/mobile/my-series	page_visit	page_visit: Rally -> /mobile/my-series	127.0.0.1	2025-05-18 13:50:58.563667
13559	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:51:12.904984
13580	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:52:22.153139
13601	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:54:32.138435
13620	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:55:07.730163
13640	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:56:23.867523
13661	rossfreedman@gmail.com	click	/mobile/my-club	button	button: 	127.0.0.1	2025-05-18 13:58:58.661555
13682	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:01:31.620599
13703	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 14:03:48.536478
13723	rossfreedman@gmail.com	click	/mobile	button	button: 	127.0.0.1	2025-05-18 14:05:03.0722
13738	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:06:14.672608
13746	rossfreedman@gmail.com	click	/mobile/myteam	page_visit	page_visit: Rally -> /mobile/myteam	127.0.0.1	2025-05-18 14:06:16.295912
13755	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:06:18.874358
12607	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:29:08.68189
12627	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:31:35.633824
12648	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:33:57.152833
12669	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:12.272695
12689	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:21.672729
12711	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-18 12:36:35.090666
12731	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:02.210794
12753	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:37:15.379818
12772	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:37:23.547741
12794	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:37:40.225377
12815	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:37:42.16701
12835	rossfreedman@gmail.com	click	/mobile	a	a: Me -> http://127.0.0.1:8080/mobile/analyze-me	127.0.0.1	2025-05-18 12:38:37.34749
12858	rossfreedman@gmail.com	click	/mobile/ask-ai	page_visit	page_visit: Rally -> /mobile/ask-ai	127.0.0.1	2025-05-18 12:38:53.422675
12878	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:42:07.760866
12899	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 12:42:10.241893
12920	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:44:21.464129
12940	rossfreedman@gmail.com	click	/mobile/analyze-me	page_visit	page_visit: Rally -> /mobile/analyze-me	127.0.0.1	2025-05-18 12:44:24.8694
12960	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:52:13.734226
12983	rossfreedman@gmail.com	click	/mobile/myteam	page_visit	page_visit: Rally -> /mobile/myteam	127.0.0.1	2025-05-18 12:52:32.320456
12982	rossfreedman@gmail.com	click	/mobile/myteam	page_visit	page_visit: Rally -> /mobile/myteam	127.0.0.1	2025-05-18 12:52:32.320437
13004	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-18 12:52:49.196646
13003	rossfreedman@gmail.com	click	/mobile	a	a: Find Sub -> http://127.0.0.1:8080/mobile/find-subs	127.0.0.1	2025-05-18 12:52:49.196665
13025	rossfreedman@gmail.com	click	/mobile	a	a: View Schedule -> http://127.0.0.1:8080/mobile/view-schedule	127.0.0.1	2025-05-18 12:57:06.499519
13045	rossfreedman@gmail.com	click	/mobile/improve	a	a: Improve my game -> http://127.0.0.1:8080/mobile/improve	127.0.0.1	2025-05-18 12:58:32.84764
13067	rossfreedman@gmail.com	click	/mobile/analyze-me	page_visit	page_visit: Rally -> /mobile/analyze-me	127.0.0.1	2025-05-18 13:01:57.79584
13087	rossfreedman@gmail.com	click	/mobile/view-schedule	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 13:02:06.84241
13108	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:07:40.972528
13128	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:09:47.348229
13149	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 13:12:04.784783
13169	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:17:00.083628
13189	rossfreedman@gmail.com	static_asset	com.chrome.devtools	\N	Accessed static asset: .well-known/appspecific/com.chrome.devtools.json	127.0.0.1	2025-05-18 13:21:45.77738
13209	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:27:43.453903
13232	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:32:27.492879
13251	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:33:57.253622
13271	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:34:05.690229
13292	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:35:20.864802
13312	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:35:38.053425
13332	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:37:52.841862
13353	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:38:22.810768
13374	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:38:33.549328
13373	rossfreedman@gmail.com	click	/mobile/availability	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 13:38:33.549365
13394	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:38:59.345936
13413	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:39:20.018348
13435	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: False	127.0.0.1	2025-05-18 13:47:42.87831
13455	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 10/29/2024, Available: False	127.0.0.1	2025-05-18 13:47:55.617176
13475	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:48:13.514846
13499	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:48:31.582683
13519	rossfreedman@gmail.com	click	/mobile/view-schedule	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 13:50:51.762378
13539	rossfreedman@gmail.com	click	/mobile/my-series	page_visit	page_visit: Rally -> /mobile/my-series	127.0.0.1	2025-05-18 13:50:58.564449
13560	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:51:12.904944
13581	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:52:22.21409
13600	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:54:32.138441
13621	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:55:07.730894
13641	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 10/01/2024, Available: False	127.0.0.1	2025-05-18 13:56:23.87573
13662	rossfreedman@gmail.com	auth	\N	logout	\N	127.0.0.1	2025-05-18 13:59:00.253815
13683	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:01:31.624158
13704	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 14:03:48.536452
13724	rossfreedman@gmail.com	auth	\N	logout	\N	127.0.0.1	2025-05-18 14:05:05.442021
12608	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-18 12:29:08.707601
12628	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 12:31:35.658642
12649	rossfreedman@gmail.com	static_asset	com.chrome.devtools	\N	Accessed static asset: .well-known/appspecific/com.chrome.devtools.json	127.0.0.1	2025-05-18 12:34:18.692969
12670	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:12.277831
12690	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:36:26.08541
12712	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:36:35.150172
12734	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:37:05.26638
12732	rossfreedman@gmail.com	page_visit	mobile_lineup	\N	\N	127.0.0.1	2025-05-18 12:37:05.266323
12752	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:15.379823
12773	rossfreedman@gmail.com	click	\N	click	Clicked button	127.0.0.1	2025-05-18 12:37:23.550561
12795	rossfreedman@gmail.com	api_access	\N	api_log-activity	Method: POST	127.0.0.1	2025-05-18 12:37:40.736182
12816	rossfreedman@gmail.com	static_asset	com.chrome.devtools	\N	Accessed static asset: .well-known/appspecific/com.chrome.devtools.json	127.0.0.1	2025-05-18 12:37:49.123144
12836	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-18 12:38:37.376438
12857	rossfreedman@gmail.com	click	/mobile/ask-ai	page_visit	page_visit: Rally -> /mobile/ask-ai	127.0.0.1	2025-05-18 12:38:53.422661
12879	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:42:07.76351
12900	rossfreedman@gmail.com	static_asset	favicon	\N	Accessed static asset: favicon.ico	127.0.0.1	2025-05-18 12:42:10.262936
12919	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:44:21.464252
12941	rossfreedman@gmail.com	click	/mobile/analyze-me	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 12:44:25.622286
12961	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 12:52:13.734321
12984	rossfreedman@gmail.com	click	/mobile/myteam	page_visit	page_visit: Rally -> /mobile/myteam	127.0.0.1	2025-05-18 12:52:32.324184
13005	rossfreedman@gmail.com	click	/mobile/find-subs	page_visit	page_visit: Rally -> /mobile/find-subs	127.0.0.1	2025-05-18 12:52:49.269129
13026	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 12:57:06.506315
13046	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-18 12:58:32.848918
13068	rossfreedman@gmail.com	click	/mobile/analyze-me	page_visit	page_visit: Rally -> /mobile/analyze-me	127.0.0.1	2025-05-18 13:01:57.802787
13088	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:02:08.89823
13109	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:07:40.972455
13129	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:09:48.90134
13150	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 13:12:04.791837
13170	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:17:00.083589
13191	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:22:24.422047
13211	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:28:53.942566
13231	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:32:27.492799
13252	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:33:57.253642
13272	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:34:05.694321
13293	rossfreedman@gmail.com	click	/mobile/availability	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 13:35:20.864746
13313	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: False	127.0.0.1	2025-05-18 13:35:38.061468
13333	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:37:52.843035
13354	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:38:22.810746
13376	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:38:33.622376
13395	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 12/10/2024, Available: True	127.0.0.1	2025-05-18 13:38:59.354726
13415	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 13:39:20.022587
13436	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 13:47:42.882448
13456	rossfreedman@gmail.com	click	/mobile/availability	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 13:47:56.969265
13476	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 11/12/2024, Available: False	127.0.0.1	2025-05-18 13:48:13.52401
13498	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:48:31.582491
13520	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:50:52.243123
13540	rossfreedman@gmail.com	click	/mobile/my-series	page_visit	page_visit: Rally -> /mobile/my-series	127.0.0.1	2025-05-18 13:50:58.565991
13561	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:51:12.908453
13582	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:52:22.214112
13602	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 13:54:32.141577
13622	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 13:55:09.168107
13642	rossfreedman@gmail.com	click	/mobile/availability	button	button: 	127.0.0.1	2025-05-18 13:56:25.147879
13663	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 13:59:00.256535
13684	rossfreedman@gmail.com	click	/mobile	button	button: 	127.0.0.1	2025-05-18 14:01:33.579835
13705	rossfreedman@gmail.com	click	/mobile/availability	page_visit	page_visit: Update Availability | Rally -> /mobile/availability	127.0.0.1	2025-05-18 14:03:48.541961
13725	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 14:05:05.441901
13737	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:06:14.672595
13747	rossfreedman@gmail.com	click	/mobile/myteam	page_visit	page_visit: Rally -> /mobile/myteam	127.0.0.1	2025-05-18 14:06:16.29596
12587	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	Accessed Ask AI page	127.0.0.1	2025-05-18 12:27:03.587818
13758	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:08:18.381863
13761	rossfreedman@gmail.com	click	/mobile	a	a:  -> http://127.0.0.1:8080/mobile	127.0.0.1	2025-05-18 14:08:19.061109
13764	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:08:19.134368
13767	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 14:08:21.612421
13770	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:08:21.669846
13773	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 14:12:09.021675
13776	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:12:09.098474
13780	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:12:09.660134
13783	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 14:12:12.884174
13785	rossfreedman@gmail.com	auth	\N	login	Successful login	127.0.0.1	2025-05-18 16:44:34.80656
13788	rossfreedman@gmail.com	click	/mobile	a	a: View Schedule -> http://127.0.0.1:8080/mobile/view-schedule	127.0.0.1	2025-05-18 16:44:36.012018
13792	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 16:44:41.252784
13796	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: False	127.0.0.1	2025-05-18 16:44:42.641944
13801	rossfreedman@gmail.com	click	/mobile/availability	button	button: 	127.0.0.1	2025-05-18 16:44:45.861513
13800	rossfreedman@gmail.com	click	/mobile/availability	button	button: 	127.0.0.1	2025-05-18 16:44:45.861549
13804	rossfreedman@gmail.com	click	/mobile/availability	a	a: Logout -> http://127.0.0.1:8080/mobile/availability#	127.0.0.1	2025-05-18 16:44:48.3206
13808	rossfreedman@gmail.com	click	/mobile/availability	a	a: Logout -> http://127.0.0.1:8080/mobile/availability#	127.0.0.1	2025-05-18 16:44:49.648371
13809	rossfreedman@gmail.com	click	/mobile/availability	a	a: Logout -> http://127.0.0.1:8080/mobile/availability#	127.0.0.1	2025-05-18 16:44:49.648428
13812	rossfreedman@gmail.com	click	/mobile/availability	a	a: Logout -> http://127.0.0.1:8080/mobile/availability#	127.0.0.1	2025-05-18 16:44:50.004617
13813	rossfreedman@gmail.com	click	/mobile/availability	a	a: Logout -> http://127.0.0.1:8080/mobile/availability#	127.0.0.1	2025-05-18 16:44:50.00468
13817	rossfreedman@gmail.com	click	/mobile/availability	button	button: 	127.0.0.1	2025-05-18 16:46:27.039406
13816	rossfreedman@gmail.com	click	/mobile/availability	button	button: 	127.0.0.1	2025-05-18 16:46:27.039367
13820	rossfreedman@gmail.com	click	/mobile/availability	a	a: Improve my game -> http://127.0.0.1:8080/mobile/improve	127.0.0.1	2025-05-18 16:46:28.260893
13823	rossfreedman@gmail.com	click	/mobile/improve	a	a: Logout -> http://127.0.0.1:8080/mobile/improve#	127.0.0.1	2025-05-18 16:46:40.126554
13826	rossfreedman@gmail.com	click	/mobile/improve	a	a: Logout -> http://127.0.0.1:8080/mobile/improve#	127.0.0.1	2025-05-18 16:46:41.257627
13829	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-18 16:48:09.154326
13832	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-18 16:48:12.639202
13835	rossfreedman@gmail.com	click	/mobile/improve	button	button: 	127.0.0.1	2025-05-18 16:48:13.565947
13838	rossfreedman@gmail.com	click	/mobile/improve	a	a: My Club -> http://127.0.0.1:8080/mobile/my-club	127.0.0.1	2025-05-18 16:48:14.670714
13842	rossfreedman@gmail.com	click	/mobile/my-club	a	a: Logout -> http://127.0.0.1:8080/mobile/my-club#	127.0.0.1	2025-05-18 16:48:21.995823
13847	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 17:04:41.770104
13849	rossfreedman@gmail.com	click	/mobile/availability	button	button: Sorry, can't	127.0.0.1	2025-05-18 17:04:43.10382
13852	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 17:04:43.526627
13855	rossfreedman@gmail.com	click	/mobile/availability	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 17:04:44.735447
13859	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 17:04:50.257914
13858	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 17:04:50.257961
13862	rossfreedman@gmail.com	click	/mobile	a	a: Lineup Escrow -> http://127.0.0.1:8080/mobile/lineup-escrow	127.0.0.1	2025-05-18 17:04:52.284779
13865	rossfreedman@gmail.com	click	/mobile/lineup-escrow	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 17:04:54.261598
13868	rossfreedman@gmail.com	click	/mobile	button	button: 	127.0.0.1	2025-05-18 17:06:22.134459
13872	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 17:07:02.525465
13875	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 17:07:04.120894
13880	rossfreedman@gmail.com	click	/mobile/availability	a	a: Logout -> http://127.0.0.1:8080/mobile/availability#	127.0.0.1	2025-05-18 17:07:08.007144
13882	rossfreedman@gmail.com	click	/mobile/availability	button	button: 	127.0.0.1	2025-05-18 17:08:15.611738
13886	rossfreedman@gmail.com	click	/mobile/availability	button	button: 	127.0.0.1	2025-05-18 17:14:23.339606
13887	rossfreedman@gmail.com	click	/mobile/availability	button	button: 	127.0.0.1	2025-05-18 17:14:23.339592
13889	rossfreedman@gmail.com	click	/mobile	button	button: 	127.0.0.1	2025-05-18 17:26:06.571222
13895	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 17:26:10.821107
13896	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 17:26:10.821048
13902	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 17:26:11.413077
13901	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 17:26:11.413139
13905	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 17:26:11.771097
13908	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 17:27:18.766135
13756	rossfreedman@gmail.com	static_asset	com.chrome.devtools	\N	Accessed static asset: .well-known/appspecific/com.chrome.devtools.json	127.0.0.1	2025-05-18 14:06:27.408633
13759	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:08:18.383613
13762	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 14:08:19.062256
13765	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:08:19.138014
13768	rossfreedman@gmail.com	auth	\N	logout	\N	127.0.0.1	2025-05-18 14:08:21.612909
13771	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:08:21.671068
13774	rossfreedman@gmail.com	click	/mobile	page_visit	page_visit: Rally -> /mobile	127.0.0.1	2025-05-18 14:12:09.09529
13777	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 14:12:09.579516
13781	rossfreedman@gmail.com	click	/mobile	button	button: 	127.0.0.1	2025-05-18 14:12:11.248552
13786	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 16:44:34.822244
13789	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-18 16:44:36.014907
13793	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 16:44:41.257924
13797	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 16:44:43.078269
13798	rossfreedman@gmail.com	click	/mobile/availability	button	button: I can play	127.0.0.1	2025-05-18 16:44:43.078138
13982	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 11:10:58.422222
13802	rossfreedman@gmail.com	click	/mobile/availability	a	a: Logout -> http://127.0.0.1:8080/mobile/availability#	127.0.0.1	2025-05-18 16:44:47.491394
13805	rossfreedman@gmail.com	click	/mobile/availability	a	a: Logout -> http://127.0.0.1:8080/mobile/availability#	127.0.0.1	2025-05-18 16:44:48.320547
13810	rossfreedman@gmail.com	click	/mobile/availability	a	a: Logout -> http://127.0.0.1:8080/mobile/availability#	127.0.0.1	2025-05-18 16:44:49.822903
13814	rossfreedman@gmail.com	click	/mobile/availability	a	a: Logout -> http://127.0.0.1:8080/mobile/availability#	127.0.0.1	2025-05-18 16:44:50.285902
13818	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-18 16:46:28.260339
13822	rossfreedman@gmail.com	click	/mobile/improve	button	button: 	127.0.0.1	2025-05-18 16:46:29.093587
13824	rossfreedman@gmail.com	click	/mobile/improve	a	a: Logout -> http://127.0.0.1:8080/mobile/improve#	127.0.0.1	2025-05-18 16:46:40.131803
13827	rossfreedman@gmail.com	click	/mobile/improve	a	a: Logout -> http://127.0.0.1:8080/mobile/improve#	127.0.0.1	2025-05-18 16:47:10.037895
13831	rossfreedman@gmail.com	click	/mobile/improve	button	button: 	127.0.0.1	2025-05-18 16:48:11.333296
13833	rossfreedman@gmail.com	click	/mobile/improve	a	a: Improve my game -> http://127.0.0.1:8080/mobile/improve	127.0.0.1	2025-05-18 16:48:12.644126
13836	rossfreedman@gmail.com	click	/mobile/improve	button	button: 	127.0.0.1	2025-05-18 16:48:13.565984
13840	rossfreedman@gmail.com	click	/mobile/my-club	button	button: 	127.0.0.1	2025-05-18 16:48:16.853777
13839	rossfreedman@gmail.com	click	/mobile/my-club	button	button: 	127.0.0.1	2025-05-18 16:48:16.853737
13843	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 17:04:40.498065
13846	rossfreedman@gmail.com	click	/mobile	a	a: Manage Availability -> http://127.0.0.1:8080/mobile/availability	127.0.0.1	2025-05-18 17:04:41.768768
13850	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: False	127.0.0.1	2025-05-18 17:04:43.113647
13853	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 09/24/2024, Available: True	127.0.0.1	2025-05-18 17:04:43.533393
13856	rossfreedman@gmail.com	click	/mobile	button	button: 	127.0.0.1	2025-05-18 17:04:48.569951
13861	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 17:04:51.469424
13863	rossfreedman@gmail.com	page_visit	mobile_lineup_escrow	\N	Accessed mobile lineup escrow page	127.0.0.1	2025-05-18 17:04:52.286736
13866	rossfreedman@gmail.com	click	/mobile/lineup-escrow	a	a:  -> javascript:history.back()	127.0.0.1	2025-05-18 17:04:54.263119
13869	rossfreedman@gmail.com	click	/mobile	button	button: 	127.0.0.1	2025-05-18 17:06:22.137643
13873	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 17:07:03.27973
13876	rossfreedman@gmail.com	click	/mobile/availability	button	button: 	127.0.0.1	2025-05-18 17:07:04.945739
13877	rossfreedman@gmail.com	click	/mobile/availability	button	button: 	127.0.0.1	2025-05-18 17:07:04.94569
13881	rossfreedman@gmail.com	click	/mobile/availability	a	a: Logout -> http://127.0.0.1:8080/mobile/availability#	127.0.0.1	2025-05-18 17:07:08.009634
13884	rossfreedman@gmail.com	click	/mobile/availability	a	a: Logout -> http://127.0.0.1:8080/mobile/availability#	127.0.0.1	2025-05-18 17:08:18.202382
13888	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-18 17:26:04.116903
13892	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 17:26:09.044406
13891	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 17:26:09.044359
13897	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 17:26:11.032009
13898	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 17:26:11.031944
13904	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 17:26:11.593025
13906	rossfreedman@gmail.com	click	/mobile	a	a: Logout -> http://127.0.0.1:8080/mobile#	127.0.0.1	2025-05-18 17:26:11.77131
13909	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 2	\N	2025-05-20 19:39:16.410007
13910	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-01, Available: 3	\N	2025-05-20 19:39:18.57194
13911	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-08, Available: 3	\N	2025-05-20 19:39:21.368497
13912	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-08, Available: 2	\N	2025-05-20 19:39:22.247374
13913	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-15, Available: 1	\N	2025-05-20 19:39:23.92699
13914	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-22, Available: 1	\N	2025-05-20 19:39:24.826024
13915	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-20 19:39:26.632923
13916	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	\N	2025-05-20 19:41:48.722937
13917	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-22, Available: 2	\N	2025-05-20 19:41:57.69516
13918	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-11-05, Available: 1	\N	2025-05-20 19:41:59.615357
13919	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	\N	2025-05-20 19:42:11.977032
13920	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	\N	2025-05-21 09:44:58.730987
13921	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 09:45:07.123541
13922	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 1	\N	2025-05-21 09:45:09.920292
13923	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 09:57:56.915014
13924	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 10:01:21.891413
13926	rossfreedman@gmail.com	click	\N	button	{"text": "Sorry, Can't", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:05:14.098438
13925	rossfreedman@gmail.com	click	\N	button	{"text": "Sorry, Can't", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:05:14.098535
13928	rossfreedman@gmail.com	click	\N	button	{"text": "Not Sure", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:05:16.773621
13927	rossfreedman@gmail.com	click	\N	button	{"text": "Not Sure", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:05:16.773643
13929	rossfreedman@gmail.com	click	\N	button	{"text": "Sorry, Can't", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:08:33.962119
13930	rossfreedman@gmail.com	click	\N	button	{"text": "Sorry, Can't", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:08:33.962151
13932	rossfreedman@gmail.com	click	\N	button	{"text": "Not Sure", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:08:38.682933
13931	rossfreedman@gmail.com	click	\N	button	{"text": "Not Sure", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:08:38.682979
13933	rossfreedman@gmail.com	click	\N	button	{"text": "Not Sure", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:08:39.93427
13934	rossfreedman@gmail.com	click	\N	button	{"text": "Not Sure", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:08:39.934126
13936	rossfreedman@gmail.com	click	\N	button	{"text": "Sorry, Can't", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:08:40.840426
13935	rossfreedman@gmail.com	click	\N	button	{"text": "Sorry, Can't", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:08:40.840368
13937	rossfreedman@gmail.com	click	\N	button	{"text": "Sorry, Can't", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:08:43.596115
13938	rossfreedman@gmail.com	click	\N	button	{"text": "Sorry, Can't", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:08:43.596086
13940	rossfreedman@gmail.com	click	\N	button	{"text": "Sorry, Can't", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:10:02.757485
13939	rossfreedman@gmail.com	click	\N	button	{"text": "Sorry, Can't", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:10:02.757449
13941	rossfreedman@gmail.com	click	\N	button	{"text": "Sorry, Can't", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:11:36.415655
13942	rossfreedman@gmail.com	click	\N	button	{"text": "Not Sure", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:11:38.108801
13943	rossfreedman@gmail.com	click	\N	button	{"text": "Sorry, Can't", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:12:41.372029
13944	rossfreedman@gmail.com	click	\N	button	{"text": "Not Sure", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:12:42.693208
13945	rossfreedman@gmail.com	click	\N	page_visit	{"text": "Update Availability | Rally", "href": "/mobile/availability", "page": "/mobile/availability"}	\N	2025-05-21 10:15:50.920833
13946	rossfreedman@gmail.com	click	\N	click	{"text": "Sorry, Can't", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:15:52.185082
13947	rossfreedman@gmail.com	click	\N	click	{"text": "Not Sure", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:15:53.501716
13948	rossfreedman@gmail.com	click	\N	page_visit	{"text": "Update Availability | Rally", "href": "/mobile/availability", "page": "/mobile/availability"}	\N	2025-05-21 10:17:55.462812
13949	rossfreedman@gmail.com	click	\N	click	{"text": "Sorry, Can't", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:17:57.350133
13950	rossfreedman@gmail.com	click	\N	click	{"text": "Not Sure", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:17:58.98384
13951	rossfreedman@gmail.com	click	\N	page_visit	{"text": "Update Availability | Rally", "href": "/mobile/availability", "page": "/mobile/availability"}	\N	2025-05-21 10:20:02.467325
13952	rossfreedman@gmail.com	click	\N	click	{"text": "Sorry, Can't", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:20:03.4722
13953	rossfreedman@gmail.com	click	\N	click	{"text": "Not Sure", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:20:05.461213
13954	rossfreedman@gmail.com	click	\N	click	{"text": "Sorry, Can't", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:20:09.481397
13955	rossfreedman@gmail.com	click	\N	page_visit	{"text": "Update Availability | Rally", "href": "/mobile/availability", "page": "/mobile/availability"}	\N	2025-05-21 10:20:22.693167
13956	rossfreedman@gmail.com	click	\N	click	{"text": "Sorry, Can't", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:20:24.014554
13957	rossfreedman@gmail.com	click	\N	page_visit	{"text": "Update Availability | Rally", "href": "/mobile/availability", "page": "/mobile/availability"}	\N	2025-05-21 10:23:57.81976
13958	rossfreedman@gmail.com	click	\N	click	{"text": "Sorry, Can't", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:23:58.772662
13959	rossfreedman@gmail.com	click	\N	click	{"text": "Not Sure", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:23:59.826268
13960	rossfreedman@gmail.com	click	\N	click	{"text": "Sorry, Can't", "href": "", "page": "/mobile/availability"}	\N	2025-05-21 10:24:00.712631
13961	rossfreedman@gmail.com	click	\N	page_visit	{"text": "Update Availability | Rally", "href": "/mobile/availability", "page": "/mobile/availability", "elementId": "", "elementType": ""}	\N	2025-05-21 10:34:54.860621
13962	rossfreedman@gmail.com	click	\N	click	{"text": "Sorry, Can't", "href": "", "page": "/mobile/availability", "elementId": "", "elementType": "button"}	\N	2025-05-21 10:34:56.080231
13963	rossfreedman@gmail.com	click	\N	click	{"text": "Not Sure", "href": "", "page": "/mobile/availability", "elementId": "", "elementType": "button"}	\N	2025-05-21 10:34:57.015626
13964	rossfreedman@gmail.com	click	\N	page_visit	{"text": "Update Availability | Rally", "href": "/mobile/availability", "page": "/mobile/availability", "elementId": "", "elementType": ""}	\N	2025-05-21 10:36:06.277939
13965	rossfreedman@gmail.com	click	\N	page_visit	{"text": "Update Availability | Rally", "href": "/mobile/availability", "page": "/mobile/availability", "elementId": "", "elementType": ""}	\N	2025-05-21 10:37:05.274136
13966	rossfreedman@gmail.com	click	\N	page_visit	{"text": "Update Availability | Rally", "href": "/mobile/availability", "page": "/mobile/availability", "elementId": "", "elementType": ""}	\N	2025-05-21 10:39:22.028231
13967	rossfreedman@gmail.com	click	\N	page_visit	{"text": "Update Availability | Rally", "href": "/mobile/availability", "page": "/mobile/availability", "elementId": "", "elementType": ""}	\N	2025-05-21 10:40:44.620176
13968	rossfreedman@gmail.com	click	\N	page_visit	{"text": "Update Availability | Rally", "href": "/mobile/availability", "page": "/mobile/availability", "elementId": "", "elementType": ""}	\N	2025-05-21 10:42:11.943253
13969	rossfreedman@gmail.com	click	\N	page_visit	{"text": "Update Availability | Rally", "href": "/mobile/availability", "page": "/mobile/availability", "elementId": "", "elementType": ""}	\N	2025-05-21 10:42:25.820782
13970	rossfreedman@gmail.com	click	\N	page_visit	{"text": "Update Availability | Rally", "href": "/mobile/availability", "page": "/mobile/availability", "elementId": "", "elementType": ""}	\N	2025-05-21 10:44:24.43605
13971	rossfreedman@gmail.com	feature_use	\N	update_availability	{"player": "Ross Freedman", "date": "2024-09-24", "status": "unavailable", "series": "Chicago 22"}	\N	2025-05-21 10:52:47.653528
13972	rossfreedman@gmail.com	feature_use	\N	update_availability	{"player": "Ross Freedman", "date": "2024-09-24", "status": "not_sure", "series": "Chicago 22"}	\N	2025-05-21 10:52:48.514585
13973	rossfreedman@gmail.com	feature_use	\N	update_availability	{"player": "Ross Freedman", "date": "2024-10-01", "status": "available", "series": "Chicago 22"}	\N	2025-05-21 10:52:49.562376
13974	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 11:05:13.162993
13975	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 2	\N	2025-05-21 11:10:44.874914
13976	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 1	\N	2025-05-21 11:10:45.578212
13977	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 3	\N	2025-05-21 11:10:46.38222
13978	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-01, Available: 1	\N	2025-05-21 11:10:48.766376
13979	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-01, Available: 3	\N	2025-05-21 11:10:50.910846
13980	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-08, Available: 3	\N	2025-05-21 11:10:52.723564
13981	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-15, Available: 2	\N	2025-05-21 11:10:56.498476
13983	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	\N	2025-05-21 11:11:06.816825
13984	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-01, Available: 1	\N	2025-05-21 11:11:12.419486
13985	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-01, Available: 2	\N	2025-05-21 11:11:14.918301
13986	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-11-05, Available: 2	\N	2025-05-21 11:11:17.847221
13987	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-29, Available: 2	\N	2025-05-21 11:11:24.640525
13988	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-29, Available: 1	\N	2025-05-21 11:11:27.654287
13989	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-29, Available: 3	\N	2025-05-21 11:11:30.42778
13990	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-11-05, Available: 1	\N	2025-05-21 11:11:34.681205
13991	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-11-05, Available: 3	\N	2025-05-21 11:11:37.161707
13992	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-11-12, Available: 1	\N	2025-05-21 11:11:39.862733
13993	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-11-05, Available: 2	\N	2025-05-21 11:12:06.973282
13994	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-29, Available: 1	\N	2025-05-21 11:13:37.192279
13995	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-29, Available: 2	\N	2025-05-21 11:13:38.076564
13996	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 1	\N	2025-05-21 11:13:41.65804
13997	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-01, Available: 1	\N	2025-05-21 11:13:42.61355
13998	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-08, Available: 1	\N	2025-05-21 11:13:43.712605
13999	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-15, Available: 3	\N	2025-05-21 11:13:46.880252
14000	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 2	\N	2025-05-21 11:14:10.561843
14001	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 3	\N	2025-05-21 11:14:11.406955
14002	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 1	\N	2025-05-21 11:14:14.16848
14003	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-01, Available: 1	\N	2025-05-21 11:14:15.802999
14004	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-01, Available: 2	\N	2025-05-21 11:14:16.272503
14005	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-01, Available: 3	\N	2025-05-21 11:14:17.031603
14006	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-08, Available: 2	\N	2025-05-21 11:14:18.891306
14007	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 1	\N	2025-05-21 11:14:22.844322
14008	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 2	\N	2025-05-21 11:14:23.729947
14009	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 3	\N	2025-05-21 11:14:24.254847
14010	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 1	\N	2025-05-21 11:15:46.480078
14011	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 2	\N	2025-05-21 11:15:47.37766
14012	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 3	\N	2025-05-21 11:15:48.231458
14013	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-01, Available: 1	\N	2025-05-21 11:15:49.219264
14014	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 2	\N	2025-05-21 11:15:50.433457
14015	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-01, Available: 2	\N	2025-05-21 11:15:51.852494
14016	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-08, Available: 1	\N	2025-05-21 11:15:54.019966
14017	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-15, Available: 1	\N	2025-05-21 11:15:54.985625
14018	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 11:15:57.45524
14019	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 3	\N	2025-05-21 11:16:14.090344
14020	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-01, Available: 3	\N	2025-05-21 11:16:14.886055
14021	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-08, Available: 2	\N	2025-05-21 11:16:17.239053
14022	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-15, Available: 2	\N	2025-05-21 11:16:18.350698
14023	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 12:22:31.510924
14024	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 1	\N	2025-05-21 12:28:12.196048
14025	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 2	\N	2025-05-21 12:28:13.095841
14026	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-01, Available: 1	\N	2025-05-21 12:28:14.233354
14027	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 1	\N	2025-05-21 12:29:15.85531
14028	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 3	\N	2025-05-21 12:29:16.728656
14029	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 2	\N	2025-05-21 12:29:17.500271
14030	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 3	\N	2025-05-21 12:31:38.260842
14031	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-10-01, Available: 2	\N	2025-05-21 12:31:39.179203
14032	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 12:48:53.233287
14033	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-21 12:48:57.64998
14034	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 12:50:06.753205
14035	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 12:50:08.630078
14036	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 12:50:14.904599
14037	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	Accessed Ask AI page	\N	2025-05-21 12:50:16.685077
14038	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 12:50:19.788709
14039	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 2	\N	2025-05-21 12:50:24.552047
14040	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 12:58:40.762632
14041	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 1	\N	2025-05-21 13:03:34.051502
14042	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 3	\N	2025-05-21 13:03:35.010057
14043	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 2	\N	2025-05-21 13:03:35.664906
14044	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 1	\N	2025-05-21 13:04:09.489751
14045	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 13:11:47.066242
14046	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 13:13:55.303986
14047	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 13:15:43.354804
14048	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 2	\N	2025-05-21 13:15:46.040023
14049	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 3	\N	2025-05-21 13:15:46.576011
14050	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 1	\N	2025-05-21 13:15:46.971886
14051	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 13:21:18.007362
14052	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 13:28:11.524207
14053	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 13:30:43.373649
14054	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	\N	2025-05-21 13:31:44.833303
14055	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 13:33:47.536604
14056	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 2	\N	2025-05-21 13:44:16.44399
14057	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 13:44:18.055557
14058	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 3	\N	2025-05-21 13:44:24.76328
14059	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Ross Freedman, Date: 2024-09-24, Available: 1	\N	2025-05-21 13:51:18.890531
14060	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 20:01:11.235817
14061	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	\N	2025-05-21 20:13:19.573122
14062	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 20:48:45.053652
14063	rossfreedman@gmail.com	page_visit	mobile_player_detail	\N	Viewed player Andrew Franger	\N	2025-05-21 21:07:46.1911
14064	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 21:08:58.377743
14065	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 21:08:59.566084
14066	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-21 21:09:00.325472
14067	rossfreedman@gmail.com	page_visit	mobile_player_detail	\N	Viewed player Will Raider	\N	2025-05-21 21:09:12.882804
14068	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-21 21:09:23.847571
14069	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-21 21:09:40.905176
14070	rossfreedman@gmail.com	page_visit	mobile_player_detail	\N	Viewed player Collin Jones	\N	2025-05-21 21:09:54.809126
14071	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 21:10:16.526781
14072	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-21 21:10:17.49244
14073	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-21 21:14:20.809814
14074	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 21:14:38.399316
14075	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	Accessed Ask AI page	\N	2025-05-21 21:14:42.840228
14076	rossfreedman@gmail.com	page_visit	mobile_lineup	\N	\N	\N	2025-05-21 21:14:49.087735
14077	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-21 21:16:25.145959
14078	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-21 21:17:15.82778
14079	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-21 21:24:31.085122
14080	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-21 21:25:46.531884
14081	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-21 21:36:29.122742
14082	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-21 21:40:47.053664
14083	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-21 21:40:48.003206
14084	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-21 21:40:49.071309
14085	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-21 21:42:27.854154
14086	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-21 21:45:11.490723
14087	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-21 21:48:49.582032
14088	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-21 21:50:52.45549
14089	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-21 21:50:53.326005
14090	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-21 21:51:30.83339
14091	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-21 21:52:45.513565
14092	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-21 21:54:47.512809
14093	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-21 21:56:19.065562
14094	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-21 21:57:25.073982
14095	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-21 21:57:54.020045
14096	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-21 21:59:55.519164
14097	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-21 21:59:56.599365
14098	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-21 22:02:44.416388
14099	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:01:09.553179
14100	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:02:24.301365
14101	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:05:17.755349
14102	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 07:07:02.022596
14103	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:07:03.5708
14104	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:10:31.226963
14105	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:12:05.90053
14106	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:13:01.179862
14107	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:13:02.269101
14108	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:14:05.773475
14109	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:18:51.760233
14110	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:20:30.876874
14111	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:27:52.083465
14112	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:28:59.329466
14113	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:29:00.861446
14114	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:29:51.5446
14115	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:30:59.505558
14116	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:31:17.385517
14117	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:31:50.42713
14118	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:32:00.285092
14119	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:32:47.881683
14120	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:33:01.6515
14121	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:33:35.923562
14122	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:33:48.430322
14123	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	\N	2025-05-22 07:34:01.872548
14124	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:34:52.642711
14125	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:34:54.7212
14126	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:35:03.676957
14127	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:35:44.376489
14128	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:36:00.172527
14129	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:37:07.112107
14130	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:37:19.631875
14131	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:38:16.887313
14132	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:38:17.999768
14133	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:39:08.562592
14134	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:39:46.108998
14135	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:40:37.497192
14136	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:40:50.830458
14137	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:42:17.796272
14138	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:43:27.334352
14139	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:50:20.982578
14140	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 07:50:21.140367
14141	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 07:50:22.386779
14142	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	\N	2025-05-22 07:50:23.592071
14143	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:50:27.429017
14144	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 07:52:00.070771
14145	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 07:52:17.679367
14146	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 07:53:00.754624
14147	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 07:53:13.538904
14148	rossfreedman@gmail.com	auth	\N	login	Successful login	\N	2025-05-22 07:54:12.959905
14149	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 07:54:12.980049
14150	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 07:54:15.172187
14151	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	\N	2025-05-22 07:54:33.925048
14152	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	\N	2025-05-22 07:58:33.494447
14153	rossfreedman@gmail.com	data_access	\N	view_data_file	File: player_history.json	\N	2025-05-22 07:58:33.636341
14154	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	\N	2025-05-22 08:01:19.737186
14155	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 08:06:37.91483
14156	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	\N	2025-05-22 08:06:46.423501
14157	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	\N	2025-05-22 09:38:09.109968
14158	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	\N	2025-05-22 09:38:55.035114
14159	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	\N	2025-05-22 09:40:38.065791
14160	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	\N	2025-05-22 09:43:05.019671
14161	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 09:43:32.50965
14162	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 09:43:35.705926
14163	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 09:44:11.245137
14164	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	\N	2025-05-22 09:44:14.061815
14165	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	\N	2025-05-22 09:47:06.539458
14166	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 09:47:08.669847
14167	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 09:47:10.128818
14168	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 14:49:19.11637
14169	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 14:49:21.634868
14170	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 14:53:10.324968
14171	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 14:53:22.729197
14172	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 14:53:24.195015
14173	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 14:55:47.878105
14174	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 14:56:17.383325
14175	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	\N	2025-05-22 14:56:19.590258
14176	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 14:56:31.53956
14177	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 15:02:16.329736
14178	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 15:08:11.78027
14179	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 15:10:37.344501
14180	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 15:11:46.07174
14181	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 15:12:30.154475
14182	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	\N	2025-05-22 15:12:30.956096
14183	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Mike Lieberman, Date: 2024-09-24, Available: 1	\N	2025-05-22 15:12:41.309517
14184	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Mike Lieberman, Date: 2024-10-01, Available: 1	\N	2025-05-22 15:12:42.115556
14185	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Mike Lieberman, Date: 2024-10-08, Available: 2	\N	2025-05-22 15:12:43.728139
14186	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Mike Lieberman, Date: 2024-10-15, Available: 3	\N	2025-05-22 15:12:45.044964
14265	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	\N	2025-05-23 08:01:01.749183
14187	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Mike Lieberman, Date: 2024-10-22, Available: 2	\N	2025-05-22 15:12:46.586544
14188	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Mike Lieberman, Date: 2024-11-05, Available: 1	\N	2025-05-22 15:12:48.227719
14189	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Mike Lieberman, Date: 2024-11-12, Available: 2	\N	2025-05-22 15:12:50.1913
14190	rossfreedman@gmail.com	feature_use	\N	update_availability	Player: Mike Lieberman, Date: 2024-11-19, Available: 1	\N	2025-05-22 15:12:51.520456
14191	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 15:13:00.540755
14192	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 15:13:03.424664
14193	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 15:13:18.310978
14194	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 15:13:41.354887
14195	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 15:17:22.562876
14196	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 15:18:01.677314
14197	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 15:49:17.176698
14198	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 15:49:20.603497
14199	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 15:50:11.225745
14200	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 15:50:12.036129
14201	rossfreedman@gmail.com	page_visit	mobile_player_detail	\N	Viewed player Brian Rosenburg	\N	2025-05-22 15:50:50.787008
14202	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-22 20:45:59.188243
14203	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-22 20:46:41.315853
14204	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-22 20:47:22.208869
14205	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 21:38:07.931721
14206	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 21:38:18.581492
14207	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 21:39:22.996173
14208	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 21:39:24.83747
14209	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	\N	2025-05-22 21:39:25.796716
14210	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 21:39:30.383828
14211	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	\N	2025-05-22 21:39:34.836418
14212	rossfreedman@gmail.com	page_visit	mobile_player_detail	\N	Viewed player Adam Markman	\N	2025-05-22 21:40:19.363691
14213	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 21:40:23.285719
14214	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 21:40:53.063516
14215	rossfreedman@gmail.com	page_visit	mobile_index	\N	\N	\N	2025-05-22 21:45:41.18861
14216	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 21:47:11.097325
14217	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 21:47:12.845516
14218	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	\N	2025-05-22 21:47:16.460753
14219	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 21:47:23.013287
14220	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 21:47:35.827916
14221	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 21:47:37.024701
14222	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	\N	2025-05-22 21:47:41.440795
14223	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 21:48:00.427145
14224	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 21:48:01.330482
14225	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	\N	2025-05-22 21:48:03.61876
14226	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	\N	2025-05-22 21:48:05.920875
14227	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 21:48:20.61408
14228	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	\N	2025-05-22 21:48:25.545067
14229	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 21:48:37.738157
14230	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 21:48:48.51537
14231	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 21:48:58.770934
14232	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-22 21:49:09.020355
14233	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-22 21:50:39.189059
14234	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 21:50:44.370027
14235	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 21:54:15.619198
14236	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	\N	2025-05-22 21:54:25.437172
14237	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 21:54:33.005021
14238	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-22 21:54:34.392303
14239	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 21:54:41.007439
14240	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 21:56:32.94242
14241	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 21:56:39.647107
14242	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 21:58:11.738058
14243	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 21:58:16.597438
14244	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 22:00:00.706467
14245	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 22:00:08.207099
14246	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-22 22:02:03.73229
14247	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-22 22:02:07.424069
14248	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 07:50:17.867927
14249	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 07:51:20.555421
14250	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 07:53:04.148961
14251	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 07:53:10.430324
14252	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 07:53:41.21141
14253	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 07:53:53.618105
14254	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 07:54:16.794618
14255	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 07:54:59.953651
14256	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 07:55:41.825808
14257	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 07:55:46.472212
14258	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 07:57:34.823969
14259	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 07:57:37.316375
14260	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 07:57:59.369062
14261	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-23 07:58:25.966819
14262	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 07:58:54.099525
14263	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 08:00:07.144449
14264	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 08:00:52.405395
14266	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 08:01:34.28348
14267	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	\N	2025-05-23 08:01:39.748396
14268	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-23 08:01:42.081211
14269	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 08:01:57.816215
14270	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 08:02:03.277737
14271	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 08:02:22.360394
14272	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	\N	2025-05-23 08:02:24.184337
14273	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 08:05:43.891235
14274	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 08:05:44.450457
14275	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 08:06:01.409656
14276	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 08:06:04.587942
14277	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 08:08:00.582292
14278	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 08:08:01.309628
14279	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	Accessed Ask AI page	\N	2025-05-23 08:08:03.150645
14280	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-23 08:08:05.113253
14281	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	\N	2025-05-23 08:08:15.464269
14282	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 08:08:42.46077
14283	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-23 08:08:44.35844
14284	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 08:10:27.580755
14285	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	\N	2025-05-23 08:10:41.089625
14286	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	\N	2025-05-23 08:11:00.673966
14287	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	\N	2025-05-23 08:11:14.460107
14288	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-23 08:11:44.410678
14289	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 08:12:13.302504
14290	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 08:12:32.813792
14291	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	\N	2025-05-23 08:13:04.243656
14292	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	\N	2025-05-23 08:14:33.940644
14293	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	\N	2025-05-23 08:15:09.32087
14294	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	\N	2025-05-23 08:16:59.05095
14295	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	\N	2025-05-23 08:17:20.147896
14296	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 08:49:54.510454
14297	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 08:52:00.863899
14298	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 08:52:03.517883
14299	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 08:52:08.43826
14300	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	\N	2025-05-23 08:52:09.400537
14301	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 08:52:24.779784
14302	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 08:52:28.825451
14303	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 08:53:20.216187
14304	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 08:54:00.436687
14305	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 08:54:01.6325
14306	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 16:18:45.387791
14307	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	\N	2025-05-23 16:18:49.025621
14308	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	Accessed Ask AI page	\N	2025-05-23 16:18:50.947859
14309	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	\N	2025-05-23 16:18:52.968766
14310	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	\N	2025-05-23 16:18:57.418189
14311	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 16:20:33.729184
14312	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 16:20:38.546159
14313	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 16:27:24.501115
14314	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 16:29:44.076449
14315	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 16:29:49.016675
14316	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 16:29:54.881193
14317	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 16:30:01.804429
14318	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 16:30:05.686314
14319	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 16:31:13.484928
14320	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 16:31:21.047912
14321	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 16:31:27.486246
14322	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 16:31:44.447582
14323	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 16:32:50.490456
14324	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 16:32:55.000687
14325	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 16:35:07.775309
14326	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 16:35:38.339442
14327	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 16:35:39.575512
14328	rossfreedman@gmail.com	admin_action	\N	delete_series	Deleted series ID 107	\N	2025-05-23 16:36:05.381983
14329	rossfreedman@gmail.com	admin_action	\N	delete_series	Deleted series ID 112	\N	2025-05-23 16:36:08.761756
14330	rossfreedman@gmail.com	admin_action	\N	delete_series	Deleted series ID 108	\N	2025-05-23 16:36:11.930754
14331	rossfreedman@gmail.com	admin_action	\N	delete_series	Deleted series ID 105	\N	2025-05-23 16:36:16.27227
14332	rossfreedman@gmail.com	admin_action	\N	delete_series	Deleted series ID 106	\N	2025-05-23 16:36:19.968985
14333	rossfreedman@gmail.com	admin_action	\N	delete_series	Deleted series ID 109	\N	2025-05-23 16:36:23.213489
14334	rossfreedman@gmail.com	admin_action	\N	delete_series	Deleted series ID 110	\N	2025-05-23 16:36:26.003443
14335	rossfreedman@gmail.com	admin_action	\N	delete_series	Deleted series ID 111	\N	2025-05-23 16:36:28.424864
14336	rossfreedman@gmail.com	admin_action	\N	delete_series	Deleted series ID 181	\N	2025-05-23 16:36:32.11504
14337	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 16:36:42.850211
14338	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 16:36:43.945874
14339	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 16:36:51.680254
14340	rossfreedman@gmail.com	admin_action	\N	update_user	Updated user rossfreedman@gmail.com	\N	2025-05-23 16:37:04.108827
14341	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 16:37:06.670469
14342	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 16:37:31.758423
14343	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 16:39:39.260998
14344	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 16:40:03.143819
14345	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 16:40:04.892091
14346	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	\N	2025-05-23 16:40:06.604352
14347	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 16:40:08.736551
14348	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 16:40:15.064131
14349	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 16:40:30.860807
14350	rossfreedman@gmail.com	page_visit	admin	\N	\N	\N	2025-05-23 16:40:37.633898
14351	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	\N	2025-05-23 16:41:02.874293
14352	rossfreedman@gmail.com	page_visit	mobile_player_detail	\N	Viewed player Marvin Husby	\N	2025-05-23 16:41:08.81133
14353	rossfreedman@gmail.com	page_visit	admin	\N	\N	127.0.0.1	2025-05-23 16:42:19.762036
14354	rossfreedman@gmail.com	page_visit	mobile_player_detail	\N	Viewed player Mike Skonie	127.0.0.1	2025-05-23 16:42:25.97291
14355	rossfreedman@gmail.com	page_visit	admin	\N	\N	127.0.0.1	2025-05-23 16:42:28.281383
14356	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-23 16:42:59.101235
14357	rossfreedman@gmail.com	page_visit	admin	\N	\N	127.0.0.1	2025-05-23 16:43:04.054359
14358	rossfreedman@gmail.com	page_visit	admin	\N	\N	127.0.0.1	2025-05-23 16:44:14.453138
14359	rossfreedman@gmail.com	page_visit	admin	\N	\N	127.0.0.1	2025-05-23 16:44:19.455159
14360	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-23 16:45:53.905999
14361	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-23 16:45:59.612009
14362	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-23 16:46:04.175603
14363	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-23 16:48:16.081117
14364	rossfreedman@gmail.com	page_visit	mobile_home	\N	Accessed mobile home page	127.0.0.1	2025-05-23 16:48:20.066901
14365	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 16:50:02.16576
14366	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 16:50:26.988032
14367	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 16:51:34.95476
14368	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 16:51:40.372002
14369	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 16:52:57.551202
14370	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 16:52:59.129415
14371	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 16:53:04.366534
14372	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 16:54:10.008878
14373	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 16:54:14.483132
14374	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 16:55:15.787211
14375	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 16:55:19.020746
14376	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 16:56:50.27289
14377	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 16:56:53.785041
14378	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 16:57:05.531376
14379	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 16:57:54.623782
14380	rossfreedman@gmail.com	page_visit	admin	\N	\N	127.0.0.1	2025-05-23 16:57:58.264086
14381	rossfreedman@gmail.com	page_visit	admin	\N	\N	127.0.0.1	2025-05-23 17:00:00.129285
14382	rossfreedman@gmail.com	admin_action	\N	delete_user	Deleted user: Adam Seyb (aseyb@aol.com)	127.0.0.1	2025-05-23 17:00:04.367692
14383	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:00:15.512729
14384	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-23 17:01:09.419148
14385	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-23 17:01:45.373173
14386	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:01:46.166914
14387	rossfreedman@gmail.com	auth	\N	logout	\N	127.0.0.1	2025-05-23 17:01:49.168357
14388	rossfreedman@gmail.com	auth	\N	login	Successful login	127.0.0.1	2025-05-23 17:02:02.552183
14389	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:02:02.564555
14390	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:03:28.907696
14391	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:03:29.486154
14392	rossfreedman@gmail.com	auth	\N	logout	\N	127.0.0.1	2025-05-23 17:03:32.749954
14393	rossfreedman@gmail.com	auth	\N	login	Successful login	127.0.0.1	2025-05-23 17:04:37.092888
14394	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:04:37.103226
14395	rossfreedman@gmail.com	auth	\N	logout	\N	127.0.0.1	2025-05-23 17:04:38.763777
14396	gswender@gmail.com	auth	\N	register	User registered successfully	127.0.0.1	2025-05-23 17:05:59.268278
14397	gswender@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:05:59.288399
14398	gswender@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-23 17:06:08.105189
14399	gswender@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	127.0.0.1	2025-05-23 17:06:38.908749
14400	gswender@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:06:42.278864
14401	gswender@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:06:48.48007
14402	gswender@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:06:53.129664
14403	gswender@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:07:12.300255
14404	gswender@gmail.com	auth	\N	logout	\N	127.0.0.1	2025-05-23 17:07:13.775949
14405	rossfreedman@gmail.com	auth	\N	login	Successful login	127.0.0.1	2025-05-23 17:07:21.262391
14406	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:07:21.278265
14407	rossfreedman@gmail.com	page_visit	admin	\N	\N	127.0.0.1	2025-05-23 17:07:26.755267
14408	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:07:39.641268
14409	rossfreedman@gmail.com	auth	\N	logout	\N	127.0.0.1	2025-05-23 17:07:40.880498
14410	gswender@gmail.com	auth	\N	login	Successful login	127.0.0.1	2025-05-23 17:07:48.68991
14411	gswender@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:07:48.704569
14412	gswender@gmail.com	page_visit	mobile_ask_ai	\N	Accessed Ask AI page	127.0.0.1	2025-05-23 17:07:50.461046
14413	gswender@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:07:51.636349
14414	gswender@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-23 17:07:52.374289
14415	gswender@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:07:53.506588
14416	gswender@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-23 17:07:54.6051
14417	gswender@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:07:55.67985
14418	gswender@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:07:58.377008
14419	gswender@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:08:07.966663
14420	gswender@gmail.com	auth	\N	logout	\N	127.0.0.1	2025-05-23 17:08:09.216442
14421	rossfreedman@gmail.com	auth	\N	login	Successful login	127.0.0.1	2025-05-23 17:08:14.821389
14422	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:08:14.839324
14423	rossfreedman@gmail.com	page_visit	admin	\N	\N	127.0.0.1	2025-05-23 17:08:18.514435
14424	rossfreedman@gmail.com	page_visit	admin	\N	\N	127.0.0.1	2025-05-23 17:11:53.108971
14425	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:11:54.584545
14426	rossfreedman@gmail.com	auth	\N	logout	\N	127.0.0.1	2025-05-23 17:11:58.188068
14427	gswender@gmail.com	auth	\N	login	Successful login	127.0.0.1	2025-05-23 17:12:06.381622
14428	gswender@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:12:06.400543
14429	gswender@gmail.com	auth	\N	logout	\N	127.0.0.1	2025-05-23 17:12:15.248905
14430	rossfreedman@gmail.com	auth	\N	login	Successful login	127.0.0.1	2025-05-23 17:12:21.860474
14431	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:12:21.876689
14432	rossfreedman@gmail.com	page_visit	admin	\N	\N	127.0.0.1	2025-05-23 17:12:26.766621
14433	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:12:55.585933
14434	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	Accessed Ask AI page	127.0.0.1	2025-05-23 17:12:57.126712
14435	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:25:26.718697
14436	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-23 17:25:38.803393
14437	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:33:20.092409
14438	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:33:20.430535
14439	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:33:22.20745
14440	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-23 17:33:22.770582
14441	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:33:23.466695
14442	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	Accessed Ask AI page	127.0.0.1	2025-05-23 17:33:24.003409
14443	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:33:24.821247
14444	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-23 17:33:25.74821
14445	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:33:26.791291
14446	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:33:28.167418
14447	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	127.0.0.1	2025-05-23 17:33:28.710068
14448	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:33:29.779471
14449	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:33:31.430005
14450	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-23 17:33:32.893225
14451	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:33:34.797735
14452	rossfreedman@gmail.com	page_visit	mobile_lineup	\N	\N	127.0.0.1	2025-05-23 17:33:46.914522
14453	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-23 17:33:52.705085
14454	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:35:57.137041
14455	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-23 17:35:58.998841
14456	rossfreedman@gmail.com	page_visit	mobile_lineup	\N	\N	127.0.0.1	2025-05-23 17:36:02.963337
14457	rossfreedman@gmail.com	page_visit	mobile_lineup	\N	\N	127.0.0.1	2025-05-23 17:36:44.675008
14458	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-23 17:36:47.583444
14459	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	Accessed Ask AI page	127.0.0.1	2025-05-23 17:37:02.312811
14460	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:40:30.081493
14461	rossfreedman@gmail.com	page_visit	mobile_lineup	\N	\N	127.0.0.1	2025-05-23 17:40:32.184777
14462	rossfreedman@gmail.com	auth	\N	logout	\N	127.0.0.1	2025-05-23 17:41:11.267522
14463	rossfreedman@gmail.com	auth	\N	login	Successful login	127.0.0.1	2025-05-23 17:41:17.762856
14464	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:41:17.776394
14465	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-23 17:41:21.774668
14466	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	Accessed Ask AI page	127.0.0.1	2025-05-23 17:41:24.645162
14467	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-23 17:41:48.990538
14468	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:41:52.605911
14469	rossfreedman@gmail.com	page_visit	mobile_lineup	\N	\N	127.0.0.1	2025-05-23 17:41:54.741092
14470	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:57:57.896976
14471	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-23 17:57:58.560597
14472	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-23 17:58:02.033742
14473	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	\N	127.0.0.1	2025-05-23 17:58:03.541255
14474	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-23 17:58:05.50513
14475	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	127.0.0.1	2025-05-23 17:58:09.327467
14476	rossfreedman@gmail.com	page_visit	mobile_player_detail	\N	Viewed player Brian Rosenburg	127.0.0.1	2025-05-23 17:58:19.097307
14477	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 17:58:22.272181
14478	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-23 17:58:29.049612
14479	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-23 18:00:43.160449
14480	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 18:00:44.170568
14481	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	127.0.0.1	2025-05-23 18:00:44.78971
14482	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 18:00:46.065582
14483	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-23 18:00:53.249317
14484	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-23 18:02:23.66554
14485	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 18:02:25.328553
14486	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-23 18:02:29.398703
14487	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 18:08:48.63991
14488	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-23 18:08:49.339249
14489	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-23 18:08:52.729874
14490	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	\N	127.0.0.1	2025-05-23 18:08:54.170465
14491	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-23 18:08:56.082763
14492	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	127.0.0.1	2025-05-23 18:09:01.379752
14493	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 18:09:09.455217
14494	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	127.0.0.1	2025-05-23 18:09:10.993151
14495	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	127.0.0.1	2025-05-23 18:09:17.44096
14496	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-23 18:09:19.568538
14497	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 18:09:56.404733
14498	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-23 18:09:59.120449
14499	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-23 18:11:07.717613
14500	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 18:11:09.138421
14501	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 18:11:42.139049
14502	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-23 18:11:52.084142
14503	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 18:13:29.822866
14504	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-23 18:13:32.393361
14505	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-23 18:18:44.851961
14506	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-23 18:22:38.877055
14507	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 20:19:01.324866
14508	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	\N	127.0.0.1	2025-05-23 20:19:02.663796
14509	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 20:26:12.511376
14510	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	\N	127.0.0.1	2025-05-23 20:26:30.599513
14511	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	\N	127.0.0.1	2025-05-23 20:28:43.916365
14512	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	\N	127.0.0.1	2025-05-23 20:32:23.967563
14513	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-23 20:32:40.462346
14514	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-23 20:35:24.232007
14515	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-23 20:35:53.627794
14516	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-23 20:36:16.170704
14517	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	\N	127.0.0.1	2025-05-23 20:39:55.757876
14518	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-23 20:40:17.87466
14519	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	\N	127.0.0.1	2025-05-23 22:32:03.27518
14520	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 22:32:05.427416
14521	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 22:33:42.650437
14522	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 22:33:59.816486
14523	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 22:35:43.433204
14524	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 22:39:59.660587
14525	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-23 22:40:03.676984
14526	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 22:42:40.985905
14527	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 22:43:31.432002
14528	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 22:43:39.405508
14529	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 22:44:25.687478
14530	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 22:52:05.06263
14531	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-23 22:52:08.518752
14532	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 22:52:15.709462
14533	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 22:53:11.60783
14534	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 22:55:36.067792
14535	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 22:55:42.565772
14536	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 22:56:47.559897
14537	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 22:57:35.674222
14538	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-23 22:57:59.335049
14539	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 23:00:33.767491
14540	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-23 23:00:40.470699
14541	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	\N	127.0.0.1	2025-05-23 23:00:42.355298
14542	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 23:00:54.87643
14543	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-23 23:01:00.999195
14544	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 07:40:23.347211
14545	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 07:43:43.965465
14546	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-24 07:43:44.966919
14547	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 07:43:49.665031
14548	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	\N	127.0.0.1	2025-05-24 07:43:51.500501
14549	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 07:44:09.170145
14550	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 07:44:11.286719
14551	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 07:45:37.697685
14552	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 07:51:28.497661
14553	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 07:54:06.00344
14554	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 08:00:07.397147
14555	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 08:00:44.099389
14556	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 08:04:06.3978
14557	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 09:14:13.375008
14558	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:14:19.140249
14559	rossfreedman@gmail.com	auth	\N	login	Login successful	127.0.0.1	2025-05-24 09:18:25.114364
14560	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:18:25.131851
14561	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:18:28.234704
14562	rossfreedman@gmail.com	auth	\N	login	Login successful	127.0.0.1	2025-05-24 09:18:40.195978
14563	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:18:40.212582
14564	eli@gmail.com	auth	\N	register	Registration successful	127.0.0.1	2025-05-24 09:23:56.18523
14565	eli@gmail.com	auth	\N	login	Login successful	127.0.0.1	2025-05-24 09:24:56.541325
14566	eli@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:24:56.553341
14567	eli@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-24 09:25:08.382778
14568	eli@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-24 09:25:10.986993
14569	eli@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 09:25:22.342458
14570	rossfreedman@gmail.com	auth	\N	login	Login successful	127.0.0.1	2025-05-24 09:25:41.892604
14571	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:25:41.908105
14572	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:30:44.175269
14573	rossfreedman@gmail.com	auth	\N	login	Login successful	127.0.0.1	2025-05-24 09:31:05.997182
14574	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:31:06.014767
14575	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:31:18.490969
14576	eli@gmail.com	auth	\N	login	Login successful	127.0.0.1	2025-05-24 09:31:28.335991
14577	eli@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:31:28.349859
14578	eli@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:32:16.36823
14579	eli@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:33:25.535853
14580	eli@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:33:34.360595
14581	brian@gmail.com	auth	\N	register	Registration successful	127.0.0.1	2025-05-24 09:34:01.313802
14582	brian@gmail.com	auth	\N	login	Login successful	127.0.0.1	2025-05-24 09:34:40.092457
14583	brian@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:34:40.109055
14584	brian@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:34:55.378453
14585	brian@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-24 09:34:58.166027
14586	brian@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:35:06.665108
14587	scott@gmail.com	auth	\N	register	Registration successful	127.0.0.1	2025-05-24 09:36:03.51995
14588	scott@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:36:03.541651
14589	scott@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-24 09:36:11.963991
14590	scott@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	127.0.0.1	2025-05-24 09:36:15.737361
14591	scott@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:38:25.35273
14592	scott@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:38:41.964454
14593	scott@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:39:04.994844
14594	scott@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 09:39:05.668618
14595	scott@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:39:06.676924
14596	scott@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:40:03.059539
14597	scott@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-24 09:40:04.983328
14598	scott@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	127.0.0.1	2025-05-24 09:40:14.150171
14599	rossfreedman@gmail.com	auth	\N	login	Login successful	127.0.0.1	2025-05-24 09:40:26.594362
14600	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:40:26.60901
14601	rossfreedman@gmail.com	page_visit	admin	\N	\N	127.0.0.1	2025-05-24 09:40:35.307069
14602	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:40:58.938576
14603	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:41:04.915466
14604	scott@gmail.com	auth	\N	login	Login successful	127.0.0.1	2025-05-24 09:41:14.164581
14605	scott@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:41:14.183439
14606	scott@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:41:20.953104
14607	scott@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:41:22.68267
14608	rossfreedman@gmail.com	auth	\N	login	Login successful	127.0.0.1	2025-05-24 09:41:31.865293
14609	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:41:31.881676
14610	rossfreedman@gmail.com	page_visit	admin	\N	\N	127.0.0.1	2025-05-24 09:41:37.67846
14611	rossfreedman@gmail.com	page_visit	admin	\N	\N	127.0.0.1	2025-05-24 09:41:47.893509
14612	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:42:00.768636
14613	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:42:01.92657
14614	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:42:51.272053
14615	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-24 09:42:52.642538
14616	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-24 09:42:55.469046
14617	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:42:56.430406
14618	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	127.0.0.1	2025-05-24 09:43:02.699846
14619	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-24 09:43:04.672747
14620	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	127.0.0.1	2025-05-24 09:43:10.394258
14621	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:43:39.756901
14622	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:44:42.84855
14623	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:45:48.572058
14624	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:45:49.994624
14625	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:45:57.813505
14626	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-24 09:46:02.232373
14627	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:46:13.691497
14628	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:47:22.124844
14629	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-24 09:47:36.418289
14630	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:49:33.42271
14631	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:55:34.058691
14632	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:55:43.599904
14633	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 09:55:47.95139
14634	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 13:05:30.652998
14635	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 13:13:57.623996
14636	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 13:15:05.874719
14637	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 13:18:20.550021
14638	rossfreedman@gmail.com	paddle_insight_search	\N	\N	Searched for: volley, found 10 results	127.0.0.1	2025-05-24 13:18:24.878272
14639	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 13:22:27.535818
14640	rossfreedman@gmail.com	paddle_insight_search	\N	\N	Searched for: serve, found 10 results	127.0.0.1	2025-05-24 13:22:32.576446
14641	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 13:23:50.720954
14642	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	\N	127.0.0.1	2025-05-24 13:23:51.637556
14643	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	\N	127.0.0.1	2025-05-24 13:24:16.190316
14644	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 13:24:19.683762
14645	rossfreedman@gmail.com	paddle_insight_search	\N	\N	Searched for: volley, found best match: Volleying And Net Play	127.0.0.1	2025-05-24 13:24:24.16661
14646	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	\N	127.0.0.1	2025-05-24 13:25:14.859765
14647	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 13:30:17.402617
14648	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 13:30:18.495731
14649	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 13:30:38.531104
14650	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 13:32:12.207148
14651	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 13:32:55.600348
14652	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 13:33:38.001755
14653	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 13:37:47.193626
14654	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 13:38:07.066557
14655	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 13:38:56.346374
14656	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 13:41:16.00712
14657	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 13:41:58.07725
14658	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 13:45:04.170256
14659	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 13:45:59.14889
14660	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 13:47:03.898113
14661	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 13:47:24.586529
14662	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 13:49:25.532073
14663	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 13:49:45.663344
14664	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 13:50:52.394963
14665	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 13:51:15.844032
14666	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 13:51:59.212112
14667	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 13:52:15.380888
14668	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 13:56:11.137221
14669	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 13:56:22.601447
14670	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 13:57:05.820335
14671	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 13:58:59.950427
14672	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 13:59:14.88986
14673	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 14:00:36.623378
14674	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 14:01:38.442647
14675	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 14:01:51.897204
14676	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 14:02:29.896366
14677	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 14:02:46.902559
14678	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 14:03:39.712098
14679	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 14:03:52.622396
14680	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 14:04:25.599074
14681	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 14:04:50.379947
14682	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 14:06:10.293388
14683	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 14:06:32.020363
14684	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 14:07:14.130718
14685	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 14:07:37.20899
14686	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 14:08:12.76151
14687	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 14:08:59.85452
14688	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 14:09:40.023343
14689	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 14:11:12.726871
14690	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 14:11:25.562484
14691	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 14:12:14.070102
14692	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 14:13:53.09191
14693	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 14:14:07.520251
14694	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 14:15:00.423458
14695	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 14:15:18.757177
14696	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 14:22:14.935028
14697	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 14:22:28.747677
14698	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 14:25:05.169265
14699	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 14:25:16.822152
14700	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 14:30:41.381039
14701	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 14:31:15.661882
14702	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 14:34:37.649196
14703	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 14:34:50.447386
14704	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 14:38:46.054272
14705	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 14:39:16.769607
14706	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 14:39:29.521686
14707	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 14:40:20.672665
14708	rossfreedman@gmail.com	page_visit	mobile_ask_ai	\N	\N	127.0.0.1	2025-05-24 14:40:23.087245
14709	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 14:40:29.836931
14710	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 14:42:44.205265
14711	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 14:42:55.752237
14712	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 14:45:00.566936
14713	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 14:45:17.062954
14714	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 14:46:01.060323
14715	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 14:46:49.299267
14716	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 14:51:28.951255
14717	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 14:51:45.452387
14718	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 14:52:46.221481
14719	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 14:53:03.055823
14720	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 14:53:40.29588
14721	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 14:54:00.635647
14722	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 14:56:18.818187
14723	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 14:56:31.966516
14724	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 14:57:58.890127
14725	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 14:58:21.65325
14726	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 15:00:09.87212
14727	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 15:00:24.733535
14728	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 15:00:30.936732
14729	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 15:00:49.748906
14730	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 15:01:05.28905
14731	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 15:03:10.952198
14732	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 15:03:25.981113
14733	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 15:05:56.312105
14734	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 15:06:06.386058
14735	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 15:07:07.02081
14736	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 15:08:24.393438
14737	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 15:08:34.672403
14738	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 15:11:41.364701
14739	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 15:11:53.903166
14740	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 15:18:20.117234
14741	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 15:22:09.447249
14742	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 15:22:29.761967
14743	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 15:23:30.561922
14744	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 15:23:43.213751
14745	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 15:26:00.12609
14746	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 15:26:12.780714
14747	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 15:27:10.642609
14748	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 15:27:22.748964
14749	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 15:27:30.335388
14750	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 15:27:31.543943
14751	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 15:27:34.479624
14752	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 15:27:35.687967
14753	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 15:27:51.706761
14754	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 15:27:52.840664
14755	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 15:28:09.434816
14756	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 15:28:30.479562
14757	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 15:30:05.797436
14758	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 15:30:23.071321
14759	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 15:39:31.008187
14760	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 15:41:17.435326
14761	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 15:42:33.47609
14762	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 15:43:20.221475
14763	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 15:43:45.226755
14764	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 15:43:58.560463
14765	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 15:45:01.239277
14766	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 15:45:03.112768
14767	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 15:45:04.041905
14768	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 15:45:27.595107
14769	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 15:46:20.518357
14770	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 15:46:23.975268
14771	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 15:46:25.116524
14772	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 15:46:39.187296
14773	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 15:46:53.037133
14774	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-24 15:47:06.537411
14775	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 17:05:56.649511
14776	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-24 17:05:58.739475
14777	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 17:06:32.317692
14778	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 17:09:46.5487
14779	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 17:09:47.323236
14780	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-24 17:11:23.543381
14781	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 17:12:13.725114
14782	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 17:14:35.424443
14783	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 17:14:48.963967
14784	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 17:27:37.46889
14785	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-24 17:27:44.744136
14786	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-25 05:55:23.103884
14787	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 05:55:24.230458
14788	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 05:56:31.125426
14789	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-25 05:58:02.086049
14790	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 05:58:03.056741
14791	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 05:58:43.255043
14792	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 06:00:16.809261
14793	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-25 06:01:40.811153
14794	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 06:01:41.903714
14795	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 06:02:45.452399
14796	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 06:04:04.938765
14797	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 06:04:18.537569
14798	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-25 06:07:11.085774
14799	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 06:07:12.316439
14800	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 06:07:26.103381
14801	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 06:08:00.574986
14802	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 06:14:11.591355
14803	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 06:14:25.175905
14804	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 06:20:24.661751
14805	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 06:20:36.907849
14806	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 06:27:33.18219
14807	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 06:29:30.606016
14808	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 06:29:54.921291
14809	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 06:33:13.295202
14810	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 06:38:42.318048
14811	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 06:39:09.638952
14812	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 06:39:26.269607
14813	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 06:48:37.423146
14814	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 06:48:57.019289
14815	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 06:49:49.801091
14816	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 06:50:04.900274
14817	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 06:55:03.600806
14818	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 06:55:19.327927
14819	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 06:57:35.618754
14820	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 06:58:37.745618
14821	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 06:58:55.742606
14822	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 06:59:28.137952
14823	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 07:00:52.107215
14824	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 07:01:05.497804
14825	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 07:06:21.518726
14826	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 07:14:17.131877
14827	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 07:14:32.608067
14828	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 07:17:19.26699
14829	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 07:17:37.747354
14830	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 07:18:46.64615
14831	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 07:19:14.805656
14832	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 07:20:30.900573
14833	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 07:20:41.777818
14834	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 07:22:02.734842
14835	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 07:22:16.132239
14836	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 07:22:27.197001
14837	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 07:22:45.044193
14838	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 07:24:48.652404
14839	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 07:25:00.681077
14840	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 07:27:54.800335
14841	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 07:28:10.39323
14842	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 07:28:47.011421
14843	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 07:31:51.681294
14844	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 07:32:05.086275
14845	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 07:34:35.173865
14846	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 07:34:50.032592
14847	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 07:35:54.634331
14848	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 07:36:10.87155
14849	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 07:38:13.154775
14850	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 07:38:25.893381
14851	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-25 08:33:28.258162
14852	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-25 08:35:22.298206
14853	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-25 08:35:23.305325
14854	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 08:35:39.893082
14855	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-25 08:52:21.446582
14856	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-25 08:52:22.869638
14857	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 08:52:23.967097
14858	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 08:53:52.263964
14859	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 08:54:12.835734
14860	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 08:55:04.966325
14861	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 08:55:19.052306
14862	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 08:56:21.209005
14863	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 08:56:34.236831
14864	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 09:05:08.033024
14865	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 09:06:07.364993
14866	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 09:07:06.681848
14867	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 09:07:09.483035
14868	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 09:07:39.013762
14869	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 09:11:38.766399
14870	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 09:19:46.96756
14871	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 09:19:56.737179
14872	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 09:20:10.569702
14873	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 09:21:18.86322
14874	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 09:21:29.413844
14875	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-25 11:50:55.956185
14876	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 11:51:02.161271
14877	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 11:51:20.753657
14878	rossfreedman@gmail.com	page_visit	admin	\N	\N	127.0.0.1	2025-05-25 15:15:46.255963
14879	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-25 15:15:48.614658
14880	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 15:15:50.88263
14881	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 15:16:07.76241
14882	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 15:16:50.241103
14883	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 15:17:17.023389
14884	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 15:18:55.438297
14885	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 16:37:21.837556
14886	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 16:37:37.695849
14887	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 16:42:12.963433
14888	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 16:42:33.473838
14889	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 16:45:13.155235
14890	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-25 16:48:59.917145
14891	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 16:49:01.802962
14892	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-25 16:57:22.735582
14893	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 16:57:27.121353
14894	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 16:57:41.096403
14895	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 16:58:14.326169
14896	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 16:58:43.295416
14897	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 16:59:01.858138
14898	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 16:59:15.193716
14899	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 17:04:56.869543
14900	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 17:05:09.017197
14901	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 17:07:09.185644
14902	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 17:07:20.455187
14903	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 17:09:43.790394
14904	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 17:09:59.759477
14905	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 17:10:31.184478
14906	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 17:12:42.323289
14907	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 17:13:39.067397
14908	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 17:14:00.78953
14909	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 17:18:37.947605
14910	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 17:18:57.088325
14911	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 17:19:20.470634
14912	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 17:22:33.96391
14913	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 17:22:51.544755
14914	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 17:23:11.202197
14915	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-25 17:23:42.13976
14916	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 17:23:43.369154
14917	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 17:24:18.190478
14918	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 17:26:13.944974
14919	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 17:27:26.838323
14920	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 17:27:44.712661
14921	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 17:29:04.588386
14922	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 17:30:48.140946
14923	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 17:31:04.994018
14924	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 17:32:55.564693
14925	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 17:33:11.457397
14926	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 17:36:24.649374
14927	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 17:36:45.246051
14928	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 17:37:50.823073
14929	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 17:38:07.881396
14930	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 17:38:26.52033
14931	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 17:39:08.757695
14932	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 17:39:25.370971
14933	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-25 17:56:07.942112
14934	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-25 17:56:37.265021
14935	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 17:56:38.619063
14936	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 17:56:54.93568
14937	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 17:58:50.436768
14938	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 18:02:40.802609
14939	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 18:02:50.540168
14940	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 18:04:32.016013
14941	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 18:06:59.890588
14942	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 18:08:58.633292
14943	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 18:09:19.619751
14944	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 18:11:05.090131
14945	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 18:11:28.248981
14946	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 18:11:54.522206
14947	unknown	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 18:19:41.678847
14948	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 18:20:16.677175
14949	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 18:20:42.322423
14950	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 18:21:03.860455
14951	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 18:21:31.28415
14952	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 18:21:50.281572
14953	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 18:22:33.758222
14954	unknown	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 18:23:50.238696
14955	unknown	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 18:24:38.287873
14956	unknown	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 18:25:28.528041
14957	unknown	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 18:25:56.368014
14958	unknown	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 18:26:16.108509
14959	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 18:27:00.713027
14960	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 18:27:14.187701
14961	unknown	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 18:28:58.197235
14962	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 18:29:30.373572
14963	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 18:29:43.832864
14964	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 18:30:07.804502
14965	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 18:31:15.677095
14966	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-25 18:31:30.248023
14967	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 18:31:50.004021
14968	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 18:32:32.776845
14969	rossfreedman@gmail.com	ai_chat	\N	\N	\N	127.0.0.1	2025-05-25 18:32:59.532347
14970	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 11:03:09.770375
14971	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 11:03:56.355797
14972	rossfreedman@gmail.com	page_visit	admin	\N	\N	127.0.0.1	2025-05-26 11:05:39.412261
14973	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 11:05:47.185661
14974	rossfreedman@gmail.com	page_visit	admin	\N	\N	127.0.0.1	2025-05-26 11:08:32.333787
14975	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 11:17:43.229561
14976	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 11:17:44.294768
14977	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-26 11:18:19.233434
14978	rossfreedman@gmail.com	page_visit	mobile_lineup	\N	\N	127.0.0.1	2025-05-26 11:18:24.317982
14979	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 11:18:27.142677
14980	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 11:19:30.575706
14981	rossfreedman@gmail.com	page_visit	admin	\N	\N	127.0.0.1	2025-05-26 11:19:36.081911
14982	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 11:20:09.146648
14983	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 11:20:15.673824
14984	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 11:20:51.647603
14985	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 11:20:54.459061
14986	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 11:21:04.350152
14987	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 11:21:06.474256
14988	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 11:21:10.901738
14989	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 11:21:14.164858
14990	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 11:25:22.083957
14991	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 11:25:31.296041
14992	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 11:29:31.378822
14993	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 11:29:32.339359
14994	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 11:29:33.318626
14995	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 11:29:33.867864
14996	rossfreedman@gmail.com	auth	\N	login	Login successful	127.0.0.1	2025-05-26 11:30:16.999001
14997	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 11:30:17.007708
14998	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 11:31:53.831642
14999	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 11:32:04.095537
15000	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 11:32:06.962343
15001	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 11:40:07.970401
15002	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 11:44:33.475057
15003	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 11:44:41.00834
15004	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 12:31:12.933149
15005	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 12:31:42.128603
15006	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-26 12:44:21.899807
15007	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 12:44:51.551748
15008	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 12:54:22.358497
15009	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 12:54:25.411177
15010	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 12:54:37.859331
15011	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 12:55:46.618423
15012	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 12:56:00.474553
15013	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 13:02:11.616113
15014	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 13:02:13.225201
15015	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 13:27:20.678778
15016	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-26 13:27:33.5119
15017	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	127.0.0.1	2025-05-26 13:27:38.286439
15018	rossfreedman@gmail.com	page_visit	mobile_lineup_escrow	\N	Accessed mobile lineup escrow page	127.0.0.1	2025-05-26 13:27:57.583487
15019	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 13:28:03.283057
15020	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-26 13:28:06.026849
15021	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 13:29:00.566334
15022	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 13:29:16.109934
15023	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-26 13:29:19.554055
15024	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-26 13:33:49.881366
15025	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 13:33:54.807245
15026	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 13:34:00.001508
15027	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 13:35:46.427809
15028	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-26 13:35:48.659773
15029	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-26 13:36:53.176134
15030	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 13:38:30.413088
15031	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-26 13:38:32.492131
15032	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-26 13:38:34.29712
15033	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 13:38:53.00389
15034	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-26 13:38:55.510238
15035	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	127.0.0.1	2025-05-26 13:45:26.36737
15036	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 13:48:08.601544
15037	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-26 13:48:17.554473
15038	rossfreedman@gmail.com	page_visit	mobile_lineup	\N	\N	127.0.0.1	2025-05-26 13:49:15.567161
15039	rossfreedman@gmail.com	page_visit	admin	\N	\N	127.0.0.1	2025-05-26 13:50:50.446877
15040	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 13:50:59.608899
15041	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-26 13:54:05.662858
15042	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-26 13:54:40.426549
15043	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-26 13:54:43.753321
15044	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 14:02:23.267972
15045	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 14:02:25.886852
15046	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 14:16:16.460716
15047	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 14:16:17.864479
15048	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-26 14:16:22.552547
15049	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-26 14:16:27.041216
15050	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 14:17:33.772891
15051	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	127.0.0.1	2025-05-26 14:17:38.259436
15052	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 14:20:01.9423
15053	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 14:20:02.335536
15054	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-26 14:20:03.23147
15055	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-26 14:22:13.813131
15056	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 14:22:16.595677
15057	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	127.0.0.1	2025-05-26 14:22:20.830977
15058	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 14:23:06.206468
15059	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-26 14:23:10.652749
15060	rossfreedman@gmail.com	page_visit	mobile_lineup_escrow	\N	Accessed mobile lineup escrow page	127.0.0.1	2025-05-26 14:23:31.087241
15061	rossfreedman@gmail.com	page_visit	mobile_lineup	\N	\N	127.0.0.1	2025-05-26 14:23:33.261721
15062	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 14:26:46.4931
15063	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-26 14:26:48.393902
15064	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-26 14:26:52.473938
15065	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 14:27:01.31261
15066	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-26 14:27:02.803409
15067	rossfreedman@gmail.com	page_visit	mobile_player_detail	\N	Viewed player John Smith	127.0.0.1	2025-05-26 14:31:52.480938
15068	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 14:39:40.57068
15069	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 14:39:41.238927
15070	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-26 14:39:46.00724
15071	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-26 14:44:26.388035
15072	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-26 14:44:33.827519
15073	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-26 15:47:48.481472
15074	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 15:48:16.750603
15075	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-26 15:48:34.466562
15076	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	127.0.0.1	2025-05-26 15:48:41.475212
15077	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 15:59:58.541036
15078	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 15:59:59.926241
15079	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-26 16:00:27.154
15080	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-26 16:00:30.081872
15081	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-26 16:00:48.133073
15082	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-26 16:06:58.021885
15083	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 16:07:10.795064
15084	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 16:07:11.908699
15085	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-26 16:07:13.071763
15086	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-26 16:07:15.021762
15087	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-26 16:07:27.453412
15088	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	127.0.0.1	2025-05-26 16:07:32.098946
15089	rossfreedman@gmail.com	page_visit	mobile_player_detail	\N	Viewed player Christopher Young	127.0.0.1	2025-05-26 16:07:39.976768
15090	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 16:07:47.76608
15091	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-26 16:07:50.66074
15092	rossfreedman@gmail.com	page_visit	mobile_lineup	\N	\N	127.0.0.1	2025-05-26 16:07:59.404695
15093	rossfreedman@gmail.com	page_visit	mobile_lineup	\N	\N	127.0.0.1	2025-05-26 16:18:14.198557
15094	rossfreedman@gmail.com	page_visit	mobile_lineup	\N	\N	127.0.0.1	2025-05-26 16:20:44.061112
15095	rossfreedman@gmail.com	page_visit	admin	\N	\N	127.0.0.1	2025-05-26 16:28:08.080503
15096	rossfreedman@gmail.com	page_visit	admin	\N	\N	127.0.0.1	2025-05-26 16:31:39.378052
15097	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 16:31:44.295811
15098	rossfreedman@gmail.com	page_visit	mobile_lineup	\N	\N	127.0.0.1	2025-05-26 16:31:47.476496
15099	rossfreedman@gmail.com	page_visit	admin	\N	\N	127.0.0.1	2025-05-26 16:32:33.054602
15100	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 16:32:42.027483
15101	rossfreedman@gmail.com	page_visit	mobile_lineup	\N	\N	127.0.0.1	2025-05-26 16:32:49.233746
15102	rossfreedman@gmail.com	page_visit	mobile_lineup	\N	\N	127.0.0.1	2025-05-26 16:32:56.307516
15103	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	127.0.0.1	2025-05-26 16:33:40.648802
15104	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-26 16:33:42.815347
15105	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-26 16:33:47.472122
15106	rossfreedman@gmail.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-26 16:33:52.919326
15107	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-26 16:34:10.593726
15108	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 16:38:47.759933
15109	rossfreedman@gmail.com	page_visit	mobile_lineup	\N	\N	127.0.0.1	2025-05-26 16:38:52.455495
15110	rossfreedman@gmail.com	page_visit	mobile_lineup	\N	\N	127.0.0.1	2025-05-26 16:39:32.470494
15111	rossfreedman@gmail.com	page_visit	mobile_lineup	\N	\N	127.0.0.1	2025-05-26 16:40:06.429991
15112	rossfreedman@gmail.com	page_visit	mobile_lineup	\N	\N	127.0.0.1	2025-05-26 16:52:21.140527
15113	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 16:52:27.449
15114	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-26 16:52:30.146695
15115	rossfreedman@gmail.com	page_visit	mobile_lineup	\N	\N	127.0.0.1	2025-05-26 16:53:19.243638
15116	rossfreedman@gmail.com	page_visit	mobile_lineup	\N	\N	127.0.0.1	2025-05-26 16:55:01.095338
15117	rossfreedman@gmail.com	page_visit	mobile_lineup	\N	\N	127.0.0.1	2025-05-26 16:56:32.421655
15118	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 16:56:38.629349
15119	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-26 22:03:05.431806
15120	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-26 22:03:07.593239
15121	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-27 10:21:42.65334
15122	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-27 10:21:45.00714
15123	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-27 10:22:15.175694
15124	rossfreedman@gmail.com	page_visit	mobile_analyze_me	\N	\N	127.0.0.1	2025-05-27 10:22:24.965033
15125	rossfreedman@gmail.com	page_visit	mobile_my_series	\N	Accessed mobile my series page	127.0.0.1	2025-05-27 10:22:30.500525
15126	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-27 10:28:45.345001
15127	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-27 10:44:13.083389
15128	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-27 10:44:29.090783
15129	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-27 10:50:11.435359
15130	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-27 10:58:59.356079
15131	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-27 11:21:45.042694
15132	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-27 11:21:46.801535
15133	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-27 11:45:51.123202
15134	rossfreedman@gmail.com	page_visit	admin	\N	\N	127.0.0.1	2025-05-27 11:45:59.081007
15135	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-27 11:46:07.031718
15136	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-27 12:06:14.044911
15137	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-27 12:27:59.115188
15138	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-27 12:30:01.857622
15139	rossfreedman@gmail.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-27 12:30:02.540661
15140	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-27 15:43:32.275888
15141	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-27 17:00:57.845383
15142	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-27 17:01:04.395148
15143	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-27 17:03:08.801347
15144	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-27 17:03:09.837721
15145	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-27 17:03:44.954253
15146	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-27 17:04:07.80883
15147	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-27 17:05:02.582112
15148	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-27 17:06:48.344097
15149	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-27 17:07:22.923223
15150	rossfreedman@gmail.com	page_visit	mobile_lineup_escrow	\N	Accessed mobile lineup escrow page	127.0.0.1	2025-05-27 17:08:56.249265
15151	rossfreedman@gmail.com	page_visit	mobile_lineup_escrow	\N	Accessed mobile lineup escrow page	127.0.0.1	2025-05-27 17:09:14.195496
15152	rossfreedman@gmail.com	page_visit	mobile_lineup_escrow	\N	Accessed mobile lineup escrow page	127.0.0.1	2025-05-27 17:09:36.535134
15153	rossfreedman@gmail.com	page_visit	mobile_lineup_escrow	\N	Accessed mobile lineup escrow page	127.0.0.1	2025-05-27 17:09:38.428704
15154	rossfreedman@gmail.com	page_visit	mobile_lineup_escrow	\N	Accessed mobile lineup escrow page	127.0.0.1	2025-05-27 17:09:40.319252
15155	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-27 17:09:44.130004
15156	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-27 17:12:10.34423
15157	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-27 17:12:11.75941
15158	rossfreedman@gmail.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-27 17:38:36.605992
15159	rossfreedman@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-27 21:29:26.563235
15160	jess@gmail.com	auth	\N	register	Registration successful	127.0.0.1	2025-05-27 21:29:53.898444
15161	jess@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-27 21:29:53.916803
15162	jess@gmail.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-28 16:26:32.780511
15163	jeff@aol.com	auth	\N	register	Registration successful	127.0.0.1	2025-05-28 16:39:51.347709
15164	jeff@aol.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-28 16:39:51.36526
15165	jeff@aol.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-28 16:39:54.314638
15166	jeff@aol.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-28 16:39:59.404988
15167	jeff@aol.com	page_visit	mobile_find_subs	\N	\N	127.0.0.1	2025-05-28 16:40:17.467218
15168	jeff@aol.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-28 16:43:50.870661
15169	jeff@aol.com	page_visit	mobile_improve	\N	Accessed improve page	127.0.0.1	2025-05-28 16:43:53.982892
15170	jeff@aol.com	page_visit	mobile_view_schedule	\N	Viewed schedule	127.0.0.1	2025-05-28 16:43:59.405293
15171	jeff@aol.com	page_visit	mobile_home	\N	\N	127.0.0.1	2025-05-28 16:50:52.225124
\.


--
-- Data for Name: user_instructions; Type: TABLE DATA; Schema: public; Owner: rossfreedman
--

COPY public.user_instructions (id, user_email, instruction, team_id, created_at, is_active) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: rossfreedman
--

COPY public.users (id, email, password_hash, first_name, last_name, club_id, series_id, club_automation_password, created_at, last_login, is_admin) FROM stdin;
8	jessfreedman@gmail.com	pbkdf2:sha256:1000000$30H2lfQJefbpXSQ9$bc29fb0d6b2605362513fd9aefedfe4dc77a591de9d478a8d5f8794c20912d27	Jess	Freedman	1	182	\N	2025-05-18 19:42:01.24637	\N	f
11	eli@gmail.com	pbkdf2:sha256:1000000$pBkaM8gy4UHrbtEG$eaa0e18ca62cf7577a2d5d62b78ad847721ab2acbf9969a2900328e78a88715b	Eli	Strick	1	182	\N	2025-05-24 09:23:56.177038	\N	f
10	gswender@gmail.com	pbkdf2:sha256:1000000$tY05q9vSZt1dwtym$fdab520f634bb80415cd39280af11896907870f312277729e40e37aea3728ac7	Greg	Swender	1	182	\N	2025-05-23 17:05:59.255728	2025-05-23 22:12:06.370328	f
13	scott@gmail.com	pbkdf2:sha256:1000000$GaKi0CEeQnN5kSTE$f93e03739918375c88f5150210ee5705522edb96f81591ef306f9ce88d2740be	Scott	Osterman	1	184	\N	2025-05-24 09:36:03.506795	\N	f
12	brian@gmail.com	pbkdf2:sha256:1000000$Baq7sRRI9Mdl5tgj$ee34577640c12244ef6e2384325ed278934c7992852fcbc0e065604bc72d48e4	Brian	Fox	1	185	\N	2025-05-24 09:34:01.30755	\N	f
7	rossfreedman@gmail.com	pbkdf2:sha256:1000000$BCn5ZqSplFW16gof$0e173f4ccce0760c41fa6207f792bcffe4cd6560a8f00e8d2b6ebed8f7cdde38	Ross	Freedman	1	184		2025-05-18 11:31:24.509828	2025-05-23 22:41:17.753073	f
14	jess@gmail.com	pbkdf2:sha256:1000000$tkOrrmrqzTpAxXEH$410fdbab62a709bd3de597fc29df4a47f190f6cdab0428be4b4cc70b44df8433	Jess	Freedman	1	184	\N	2025-05-27 21:29:53.886054	\N	f
15	jeff@aol.com	pbkdf2:sha256:1000000$mHfGBS6ePFq42qaF$3c100a316afbe4de02b90b05c5c3211c12b34a8fd6800a71113ae7aa61192212	Ross	Freedman	1	184		2025-05-28 16:39:51.336729	\N	f
\.


--
-- Name: clubs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: rossfreedman
--

SELECT pg_catalog.setval('public.clubs_id_seq', 183, true);


--
-- Name: player_availability_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.player_availability_id_seq', 150, true);


--
-- Name: series_id_seq; Type: SEQUENCE SET; Schema: public; Owner: rossfreedman
--

SELECT pg_catalog.setval('public.series_id_seq', 185, true);


--
-- Name: user_activity_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: rossfreedman
--

SELECT pg_catalog.setval('public.user_activity_logs_id_seq', 15171, true);


--
-- Name: user_instructions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: rossfreedman
--

SELECT pg_catalog.setval('public.user_instructions_id_seq', 30, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: rossfreedman
--

SELECT pg_catalog.setval('public.users_id_seq', 15, true);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: clubs clubs_name_key; Type: CONSTRAINT; Schema: public; Owner: rossfreedman
--

ALTER TABLE ONLY public.clubs
    ADD CONSTRAINT clubs_name_key UNIQUE (name);


--
-- Name: clubs clubs_pkey; Type: CONSTRAINT; Schema: public; Owner: rossfreedman
--

ALTER TABLE ONLY public.clubs
    ADD CONSTRAINT clubs_pkey PRIMARY KEY (id);


--
-- Name: player_availability player_availability_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_availability
    ADD CONSTRAINT player_availability_pkey PRIMARY KEY (id);


--
-- Name: player_availability player_availability_player_name_match_date_series_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_availability
    ADD CONSTRAINT player_availability_player_name_match_date_series_id_key UNIQUE (player_name, match_date, series_id);


--
-- Name: series series_name_key; Type: CONSTRAINT; Schema: public; Owner: rossfreedman
--

ALTER TABLE ONLY public.series
    ADD CONSTRAINT series_name_key UNIQUE (name);


--
-- Name: series series_pkey; Type: CONSTRAINT; Schema: public; Owner: rossfreedman
--

ALTER TABLE ONLY public.series
    ADD CONSTRAINT series_pkey PRIMARY KEY (id);


--
-- Name: user_activity_logs user_activity_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: rossfreedman
--

ALTER TABLE ONLY public.user_activity_logs
    ADD CONSTRAINT user_activity_logs_pkey PRIMARY KEY (id);


--
-- Name: user_instructions user_instructions_pkey; Type: CONSTRAINT; Schema: public; Owner: rossfreedman
--

ALTER TABLE ONLY public.user_instructions
    ADD CONSTRAINT user_instructions_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: rossfreedman
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: rossfreedman
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_player_availability; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_player_availability ON public.player_availability USING btree (player_name, match_date, series_id);


--
-- Name: player_availability player_availability_series_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_availability
    ADD CONSTRAINT player_availability_series_id_fkey FOREIGN KEY (series_id) REFERENCES public.series(id);


--
-- Name: users users_club_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: rossfreedman
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_club_id_fkey FOREIGN KEY (club_id) REFERENCES public.clubs(id);


--
-- Name: users users_series_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: rossfreedman
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_series_id_fkey FOREIGN KEY (series_id) REFERENCES public.series(id);


--
-- PostgreSQL database dump complete
--

