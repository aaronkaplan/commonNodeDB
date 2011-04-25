
-- 
-- please check the README and TODO files

--
-- PostgreSQL database dump
--




SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: nodedb; Type: DATABASE; Schema: -; Owner: developers
--

CREATE DATABASE nodedb WITH TEMPLATE = template0 ENCODING = 'UTF8';


ALTER DATABASE nodedb OWNER TO "developers";

\connect nodedb

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: implementation; Type: SCHEMA; Schema: -; Owner: developers
--

CREATE SCHEMA implementation;


ALTER SCHEMA implementation OWNER TO "developers";

--
-- Name: SCHEMA implementation; Type: COMMENT; Schema: -; Owner: developers
--

COMMENT ON SCHEMA implementation IS 'this contains tables, keys, constraints, all stuff that will not be exposed to any external interface';


--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: postgres
--

CREATE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO postgres;

SET search_path = implementation, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: standardtable; Type: TABLE; Schema: implementation; Owner: developers; Tablespace: 
--

CREATE TABLE standardtable (
    id bigint NOT NULL,
    created timestamp with time zone DEFAULT now() NOT NULL,
    changed timestamp with time zone DEFAULT now() NOT NULL
);



ALTER TABLE implementation.standardtable OWNER TO "developers";

--
-- Name: TABLE standardtable; Type: COMMENT; Schema: implementation; Owner: developers
--

COMMENT ON TABLE standardtable IS 'All tables inherit from this. This has these consequences:
a) all tables have a "changed" timestamp column which is automatically set in updates
b) all tables have a "created" timestamp column which is automatically set upon insert
c) all tables have an id column 
d) this id column shares the same id space (an 64bit integer so that should suffice for quite a while); the nice thing about this is that any record in our database can be uniquely identified by this id without knowing which table it belongs to; database-wise this is not needed, but it could become practical for code accessing the database';


--
-- Name: standardtable_id_seq; Type: SEQUENCE; Schema: implementation; Owner: developers
--

CREATE SEQUENCE standardtable_id_seq
    START WITH 1000
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE implementation.standardtable_id_seq OWNER TO "developers";

--
-- Name: standardtable_id_seq; Type: SEQUENCE OWNED BY; Schema: implementation; Owner: developers
--

ALTER SEQUENCE standardtable_id_seq OWNED BY standardtable.id;

--
-- Name: gps; Type: TYPE; Schema: implementation; Owner: developers
--

CREATE TYPE gps AS (
	latitude double precision,
	longitude double precision,
	height double precision
);


ALTER TYPE implementation.gps OWNER TO "developers";

--
-- Name: addresses; Type: TABLE; Schema: implementation; Owner: developers; Tablespace: 
--

CREATE TABLE addresses (
    country character varying NOT NULL,
    state character varying NOT NULL,
    city character varying NOT NULL,
    zip character varying NOT NULL,
    street character varying NOT NULL,
    "position" gps NOT NULL
)
INHERITS (standardtable);


ALTER TABLE implementation.addresses OWNER TO "developers";

--
-- Name: COLUMN addresses.street; Type: COMMENT; Schema: implementation; Owner: developers
--

COMMENT ON COLUMN addresses.street IS 'including house number etc.';



--
-- Name: antennas; Type: TABLE; Schema: implementation; Owner: developers; Tablespace: 
--

CREATE TABLE antennas (
    antennatype_id bigint NOT NULL,
    radio_id bigint NOT NULL,
    polarization character varying, -- horizontal, vertical, circular right hand, circular left hand
    azimuth float NOT NULL,
    inclination float 
)
INHERITS (standardtable);

COMMENT ON COLUMN antennas.azimuth      IS 'degrees (0-360 deg), north is 0 degrees, 90 is east (clockwise). See http://en.wikipedia.org/wiki/Azimuth';
COMMENT ON COLUMN antennas.inclination  IS 'degrees in the vertical plane. 0 is even (horizontal) http://en.wikipedia.org/wiki/Inclination';
COMMENT ON COLUMN antennas.polarization IS 'horizontal, vertical, circular right hand, circular left hand';



ALTER TABLE implementation.antennas OWNER TO "developers";


--
-- Name: links; Type: TABLE; Schema: implementation; Owner: developers; Tablespace: 
--
CREATE TABLE links (
  lq  float,
  snr float,
  a   bigint NOT NULL,  -- references interface_id
  b   bigint NOT NULL   -- references interface_id
) 
INHERITS (standardtable);

ALTER TABLE implementation.links OWNER TO "developers";

COMMENT ON TABLE links IS 'need to still think how this relates to interfaces2logrecords... maybe duplicate stuff!';

--
-- Name: zone_types; Type: TABLE; Schema: implementation; Owner: developers; Tablespace: 
--
CREATE TABLE zone_types (
   "type" character varying UNIQUE NOT NULL 
)
INHERITS (standardtable);

INSERT INTO zone_types (id, "type") VALUES(1, 'OLSR');
INSERT INTO zone_types (id, "type") VALUES(2, 'OSPF');
INSERT INTO zone_types (id, "type") VALUES(3, 'BGP');
INSERT INTO zone_types (id, "type") VALUES(4, 'Babel');
INSERT INTO zone_types (id, "type") VALUES(5, 'IS-IS');
INSERT INTO zone_types (id, "type") VALUES(6, 'RIPv2');
INSERT INTO zone_types (id, "type") VALUES(7, '802.11s');
INSERT INTO zone_types (id, "type") VALUES(8, 'BATMAN');

ALTER TABLE implementation.zone_types OWNER TO "developers";
--
-- Name: zones; Type: TABLE; Schema: implementation; Owner: developers; Tablespace: 
--
CREATE TABLE zones (
    name  character varying NOT NULL,
    type_id  bigint DEFAULT 0 NOT NULL,  -- references zone_types
	-- XXX FIXME: this needs to be defined better
	parent_zone_id bigint
	-- XXX seperate zones from networks
)
INHERITS (standardtable);
    
ALTER TABLE implementation.zones OWNER TO "developers";
    
--
-- Name: nodes; Type: TABLE; Schema: implementation; Owner: developers; Tablespace: 
--
CREATE TABLE nodes (
    name character varying NOT NULL,
    map boolean default true NOT NULL,
    zone_id bigint NOT NULL, -- XXXXX attention : how to integrate border gws
    address_id bigint NOT NULL,
    admin_c_id bigint NOT NULL,
    tech_c_id bigint NOT NULL
)
INHERITS (standardtable);


ALTER TABLE implementation.nodes OWNER TO "developers";


--
-- Name: devices; Type: TABLE; Schema: implementation; Owner: developers; Tablespace: 
--

CREATE TABLE devices (
    name character varying NOT NULL,
    node_id bigint NOT NULL,
    devicetype_id bigint NOT NULL,
    runs_version_id bigint NOT NULL,
    authentificationtoken character varying NOT NULL
)
INHERITS (standardtable);


ALTER TABLE implementation.devices OWNER TO "developers";

--
-- Name: manufacturers; Type: TABLE; Schema: implementation; Owner: developers; Tablespace: 
--
CREATE TABLE manufacturers (
   name character varying NOT NULL,
   url  character varying
)
INHERITS (standardtable);
ALTER TABLE implementation.manufacturers OWNER TO "developers";

INSERT INTO manufacturers (id, name, url) VALUES (10, 'Other', '');
INSERT INTO manufacturers (id, name, url) VALUES (11, 'Linksys', 'http://www.linksys.com');
INSERT INTO manufacturers (id, name, url) VALUES (12, 'Fon', 'http://www.fon.com');
INSERT INTO manufacturers (id, name, url) VALUES (13, 'PcEngines', 'http://www.pcengines.ch');
INSERT INTO manufacturers (id, name, url) VALUES (14, 'Osbridge', 'http://www.osbridge.com');
INSERT INTO manufacturers (id, name, url) VALUES (15, 'D-Link', 'http://www.dlink.com');
INSERT INTO manufacturers (id, name, url) VALUES (16, 'Conceptonic', 'http://www.conceptronic.net/');
INSERT INTO manufacturers (id, name, url) VALUES (17, 'US Robotics', 'http://www.usr.com');
INSERT INTO manufacturers (id, name, url) VALUES (18, '3Com', 'http://www.3com.com');
INSERT INTO manufacturers (id, name, url) VALUES (19, 'Zyxel', 'http://www.zyxel.com');
INSERT INTO manufacturers (id, name, url) VALUES (20, 'Conceptronic', NULL);
INSERT INTO manufacturers (id, name, url) VALUES (21, 'Mikrotik', 'http://mikrotik.com');
INSERT INTO manufacturers (id, name, url) VALUES (22, 'Buffalo', 'http://www.buffalotech.com');
INSERT INTO manufacturers (id, name, url) VALUES (23, 'Ubiquiti', 'http://www.ubnt.com');
INSERT INTO manufacturers (id, name, url) VALUES (24, 'Meraki', 'http://meraki.com');
INSERT INTO manufacturers (id, name, url) VALUES (25, 'Gateworks', 'http://www.gateworks.com');
INSERT INTO manufacturers (id, name, url) VALUES (26, 'Asus', 'http://asus.com');


--
-- Name: devicetypes; Type: TABLE; Schema: implementation; Owner: developers; Tablespace: 
--

CREATE TABLE devicetypes (
    name character varying NOT NULL, -- "antenna", "radio",  "generic wlan router", "linksys WRT", "mikrotik RB"...
    pic_url character varying,
    manual_url character varying, -- documentation, manual
    model character varying NOT NULL,
    revision character varying NOT NULL,
    manufacturer_id bigint NOT NULL,
	mac_addr_prefix mac
)
INHERITS (standardtable);


ALTER TABLE implementation.devicetypes OWNER TO "developers";

INSERT INTO devicetypes (id,  name, pic_url, manual_url, model, revision, manufacturer_id ) VALUES (40, 'osbridge', 'http://osbridge.com/themes/aberdeen/images/5GXi_mini.gif', 'http://www.osbridge.com/download/OSBRiDGE_5GXi.pdf', '5GXi', '?', 14);

--
-- Name: antennatypes
CREATE TABLE antennatypes (
    name character varying NOT NULL,
    gain float NOT NULL,
    pic_url character varying,
	freq_range_lower float, -- in MHz
	freq_range_higher float, -- in MHz --XXX
    radiation_pattern_url_h  character varying, -- XXX
    radiation_pattern_url_v  character varying,
    radiation_pattern_url_3d  character varying,
    manufacturer_id bigint NOT NULL
)
INHERITS (standardtable);


ALTER TABLE implementation.antennatypes OWNER TO "developers";

-- XXX add sample




--
-- Name: interfacemode; Type: DOMAIN; Schema: implementation; Owner: developers
--

-- should we not have an enum for that?
CREATE DOMAIN interfacemode AS smallint NOT NULL
	CONSTRAINT interfacemode_check CHECK (((VALUE >= 0) AND (VALUE <= 3)));


ALTER DOMAIN implementation.interfacemode OWNER TO "developers";

--
-- Name: DOMAIN interfacemode; Type: COMMENT; Schema: implementation; Owner: developers
--

COMMENT ON DOMAIN interfacemode IS '
0..access point (ap)
1..adhoc
2..monitor mode
3.client (station)
';

CREATE DOMAIN instant_messenger AS smallint NOT NULL
	CONSTRAINT instant_messenger_check CHECK (((VALUE >=0) AND (VALUE <= 3)));

COMMENT ON DOMAIN instant_messenger IS '
0..jabber
1.. skype
2.. irc
3.. other/unknown
';

--
-- Name: macprotocol; Type: DOMAIN; Schema: implementation; Owner: developers
--

CREATE DOMAIN macprotocol AS smallint NOT NULL
	CONSTRAINT macprotocol_check CHECK (((VALUE >= 0) AND (VALUE <= 1)));


ALTER DOMAIN implementation.macprotocol OWNER TO "developers";

--
-- Name: DOMAIN macprotocol; Type: COMMENT; Schema: implementation; Owner: developers
--

COMMENT ON DOMAIN macprotocol IS '
0..LAN
1..WLAN
';


--
-- Name: interfaces; Type: TABLE; Schema: implementation; Owner: developers; Tablespace: 
--

CREATE TABLE interfaces (
    device_id bigint NOT NULL,
    radio_id bigint, 
    interfacetype_id bigint NOT NULL,
    mac macaddr NOT NULL,
    macprotocol macprotocol NOT NULL,
	smokeping boolean, -- ping it?
	-- XXX can be deleted?
    isactive boolean DEFAULT false NOT NULL
)
INHERITS (standardtable);


ALTER TABLE implementation.interfaces OWNER TO "developers";



--
-- Name: Radio; Type: TABLE; Schema: implementation; Owner: developers; Tablespace:
--
CREATE TABLE radios (
    device_id bigint NOT NULL, -- references the generic device table
    mode interfacemode NOT NULL,
	wifimode character varying NOT NULL, -- XXX formalize that somehwer like interfacemode ... 802.11a , b, g, nstreme2
    channel bigint NOT NULL, -- would it be better to have the freq ?
    ssid character varying NOT NULL,
    bssid character varying,
    encryptiontype character varying NOT NULL,
    encryptionkey character varying,
    transmitpower double precision, -- in dBm
    distance integer,	-- in meters
    ishidden boolean DEFAULT false NOT NULL,
    isactive boolean DEFAULT false NOT NULL,
	-- diversity , -- countrymode, -- channelwidth (turbomode?), 
	-- XXX have to think about that how it is with many different devices/manufacturers...
	config_bla character varying
)
INHERITS (standardtable);

ALTER TABLE implementation.radios OWNER TO "developers";


-- XXX missing: link table!

-- VPN table is missing?

--
-- Name: COLUMN interfaces.encryptiontype; Type: COMMENT; Schema: implementation; Owner: developers
--

COMMENT ON COLUMN radios.encryptiontype IS 'TODO: create a domain for this once valid values are known';

--
-- Name: interfaces2logrecords; Type: TABLE; Schema: implementation; Owner: developers; Tablespace: 
--

CREATE TABLE interfaces2logrecords (
    interface_id bigint NOT NULL,
    otherinterface_id bigint NOT NULL,
    logrecord_id bigint NOT NULL
)
INHERITS (standardtable); -- NOTE: add a primary key id for phpCake


ALTER TABLE implementation.interfaces2logrecords OWNER TO "developers";


--
-- Name: ips; Type: TABLE; Schema: implementation; Owner: developers; Tablespace: 
--

CREATE TABLE ips (
    interface_id bigint,
    ip inet NOT NULL,
	network bigint, -- references the network table XXX
    dns_forward boolean NOT NULL,
    custom_forward_dns character varying,
    dns_reverse boolean NOT NULL,
    custom_reverse_dns character varying,
    isalias boolean DEFAULT false NOT NULL  -- i.e. this is not a primary IP XXX is that necessary?
)
INHERITS (standardtable);


ALTER TABLE implementation.ips OWNER TO "developers";

--
-- Name: TABLE ips; Type: COMMENT; Schema: implementation; Owner: developers
--





--
-- Name: locationlogs; Type: TABLE; Schema: implementation; Owner: developers; Tablespace: 
--

CREATE TABLE locationlogs (
    device_id bigint NOT NULL,
    ts  timestamp with time zone DEFAULT now() NOT NULL,
    "position" gps NOT NULL
)
INHERITS (standardtable);


ALTER TABLE implementation.locationlogs OWNER TO "developers";

--
-- Name: logrecords; Type: TABLE; Schema: implementation; Owner: developers; Tablespace: 
--

CREATE TABLE logrecords (
	ts timestamp with time zone DEFAULT now() not null,
    key character varying NOT NULL,
    value double precision NOT NULL,
    value_avg double precision NOT NULL,
    value_stddev double precision NOT NULL
)
INHERITS (standardtable);


ALTER TABLE implementation.logrecords OWNER TO "developers";

--
-- Name: person; Type: TABLE; Schema: implementation; Owner: developers; Tablespace: 
--

CREATE TABLE person (
    firstname character varying,
    lastname character varying,
    organization character varying,
    nick character varying NOT NULL,
    password character varying NOT NULL,
    address_id bigint,  -- references addresses table
    telephone character varying,
    fax character varying,
    mobilephone character varying,
    email character varying,
	instant_messenger_id instant_messenger DEFAULT 3,
    instant_messenger_nick character varying,
    homepage character varying,
	mentor_person bigint,  -- who is the mentor for that guy?
    has_confirmed_email boolean DEFAULT false NOT NULL,
    has_signed_contract boolean DEFAULT false NOT NULL,
    has_accepted_useterms boolean DEFAULT false NOT NULL
)
INHERITS (standardtable);


ALTER TABLE implementation.person OWNER TO "developers";


--
-- Name: roles; Type: TABLE; Schema: implementation; Owner: developers; Tablespace: 
--

CREATE TABLE roles (
    name character varying NOT NULL
)
INHERITS (standardtable);


ALTER TABLE implementation.roles OWNER TO "developers";

--
-- Name: roles2person; Type: TABLE; Schema: implementation; Owner: developers; Tablespace: 
--

CREATE TABLE roles2person (
    privilege_id bigint NOT NULL,
    person_id bigint NOT NULL
);


ALTER TABLE implementation.roles2person OWNER TO "developers";

--
-- Name: sensors; Type: TABLE; Schema: implementation; Owner: developers; Tablespace: 
--

CREATE TABLE sensors (
    device_id bigint NOT NULL,
    sensortype_id bigint NOT NULL
)
INHERITS (standardtable);


ALTER TABLE implementation.sensors OWNER TO "developers";

--
-- Name: sensors2logrecords; Type: TABLE; Schema: implementation; Owner: developers; Tablespace: 
--

CREATE TABLE sensors2logrecords (
    sensor_id bigint NOT NULL,
    logrecord_id bigint NOT NULL
)
INHERITS (standardtable);


ALTER TABLE implementation.sensors2logrecords OWNER TO "developers";

--
-- Name: ipprotocol; Type: DOMAIN; Schema: implementation; Owner: developers
--

CREATE DOMAIN ipprotocol AS smallint NOT NULL
	CONSTRAINT ipprotocol_check CHECK (((VALUE >= 0) AND (VALUE <= 1)));


ALTER DOMAIN implementation.ipprotocol OWNER TO "developers";

--
-- Name: DOMAIN ipprotocol; Type: COMMENT; Schema: implementation; Owner: developers
--

COMMENT ON DOMAIN ipprotocol IS '0..TCP
1..UDP';


--
-- Name: services; Type: TABLE; Schema: implementation; Owner: developers; Tablespace: 
--

CREATE TABLE services (
    ip_id bigint NOT NULL,
    port smallint NOT NULL,
    name character varying NOT NULL,
    url character varying,
    isactive boolean DEFAULT false NOT NULL,
    info character varying,
    protocol ipprotocol NOT NULL
)
INHERITS (standardtable);


ALTER TABLE implementation.services OWNER TO "developers";

--
-- Name: updates; Type: TABLE; Schema: implementation; Owner: developers; Tablespace: 
--

CREATE TABLE updates (
    fromversion bigint NOT NULL,
    toversion bigint NOT NULL,
    patchurl character varying NOT NULL
)
INHERITS (standardtable);


ALTER TABLE implementation.updates OWNER TO "developers";

--
-- Name: versions; Type: TABLE; Schema: implementation; Owner: developers; Tablespace: 
--

-- can also point to devices XXX
CREATE TABLE versions (
    software_name character varying NOT NULL,
    major smallint, 
    minor smallint,
    build smallint
)
INHERITS (standardtable);


ALTER TABLE implementation.versions OWNER TO "developers";

--
-- Name: id; Type: DEFAULT; Schema: implementation; Owner: developers
--

ALTER TABLE standardtable ALTER COLUMN id SET DEFAULT nextval('standardtable_id_seq'::regclass);


--
-- Name: pk_manufacturers; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY manufacturers
    ADD CONSTRAINT pk_manufacturers PRIMARY KEY (id);


--
-- Name: pk_zones; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY zones
    ADD CONSTRAINT pk_zones PRIMARY KEY (id);


--
-- Name: pk_zone_types; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY zone_types
    ADD CONSTRAINT pk_zone_types PRIMARY KEY (id);


--
-- Name: pk_addresses; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY addresses
    ADD CONSTRAINT pk_addresses PRIMARY KEY (id);


--
-- Name: pk_antennas; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY antennas
    ADD CONSTRAINT pk_antennas PRIMARY KEY (id);


--
-- Name: pk_links; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY links
    ADD CONSTRAINT pk_links PRIMARY KEY (id);

--
-- Name: pk_nodes; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY nodes
    ADD CONSTRAINT pk_nodes PRIMARY KEY (id);


--
-- Name: pk_devices; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY devices
    ADD CONSTRAINT pk_devices PRIMARY KEY (id);


--
-- Name: pk_devicetypes; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY devicetypes
    ADD CONSTRAINT pk_devicetypes PRIMARY KEY (id);

--
-- Name: pk_antennatypes; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY antennatypes
    ADD CONSTRAINT pk_antennatypes PRIMARY KEY (id);



--
-- Name: pk_interfaces; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY interfaces
    ADD CONSTRAINT pk_interfaces PRIMARY KEY (id);


--
-- Name: pk_interfaces2logrecords; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY interfaces2logrecords
    ADD CONSTRAINT pk_interfaces2logrecords PRIMARY KEY (id);


--
-- Name: pk_ips; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY ips
    ADD CONSTRAINT pk_ips PRIMARY KEY (id);


--
-- Name: pk_locationlogs; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY locationlogs
    ADD CONSTRAINT pk_locationlogs PRIMARY KEY (id);


--
-- Name: pk_logs; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY logrecords
    ADD CONSTRAINT pk_logs PRIMARY KEY (id);


--
-- Name: pk_person; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY person
    ADD CONSTRAINT pk_person PRIMARY KEY (id);


--
-- Name: pk_roles; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT pk_roles PRIMARY KEY (id);


--
-- Name: pk_roles2person; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY roles2person
    ADD CONSTRAINT pk_roles2person PRIMARY KEY (privilege_id, person_id);


--
-- Name: pk_sensors; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY sensors
    ADD CONSTRAINT pk_sensors PRIMARY KEY (id);


--
-- Name: pk_radios; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY radios
    ADD CONSTRAINT pk_radio PRIMARY KEY (id);


--
-- Name: pk_sensors2logrecords; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY sensors2logrecords
    ADD CONSTRAINT pk_sensors2logrecords PRIMARY KEY (id);


--
-- Name: pk_services; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY services
    ADD CONSTRAINT pk_services PRIMARY KEY (id);


--
-- Name: pk_standardtable; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY standardtable
    ADD CONSTRAINT pk_standardtable PRIMARY KEY (id);


--
-- Name: pk_updates; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY updates
    ADD CONSTRAINT pk_updates PRIMARY KEY (id);


--
-- Name: pk_versions; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT pk_versions PRIMARY KEY (id);


--
-- Name: unique_devicetypes; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY devicetypes
    ADD CONSTRAINT unique_devicetypes UNIQUE (name, model, revision, manufacturer_id);



--
-- Name: unique_ips; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY ips
    ADD CONSTRAINT unique_ips UNIQUE ("cidr");


--
-- Name: unique_services; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY services
    ADD CONSTRAINT unique_services UNIQUE (ip_id, port);


--
-- Name: unique_updates; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY updates
    ADD CONSTRAINT unique_updates UNIQUE (fromversion, toversion);


--
-- Name: unique_version; Type: CONSTRAINT; Schema: implementation; Owner: developers; Tablespace: 
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT unique_version UNIQUE (software_name, major, minor, build);


--
-- Name: fki_ref_devices_versions; Type: INDEX; Schema: implementation; Owner: developers; Tablespace: 
--

CREATE INDEX fki_ref_devices_versions ON devices USING btree (runs_version_id);


--
-- Name: fki_ref_links_a; Type: INDEX; Schema: implementation; Owner: developers; Tablespace: 
--

CREATE INDEX fki_ref_links_a ON links USING btree (a);

--
-- Name: fki_ref_links_b; Type: INDEX; Schema: implementation; Owner: developers; Tablespace: 
--

CREATE INDEX fki_ref_links_b ON links USING btree (b);

--
-- Name: fki_ref_links_interfaces2; Type: INDEX; Schema: implementation; Owner: developers; Tablespace: 
--

CREATE INDEX fki_ref_links_changed ON links USING btree (changed);

--
-- Name: ref_antennatypes_manufacturer; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY antennatypes
    ADD CONSTRAINT ref_antennatypes_manufacturer FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(id) ON UPDATE CASCADE ON DELETE RESTRICT;



--
-- Name: ref_links_interfaces_a; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY links
    ADD CONSTRAINT ref_links_interfaces_a FOREIGN KEY (a) REFERENCES interfaces(id) ON UPDATE CASCADE ON DELETE RESTRICT;

--
-- Name: ref_links_interfaces_b; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY links
    ADD CONSTRAINT ref_links_interfaces_b FOREIGN KEY (b) REFERENCES interfaces(id) ON UPDATE CASCADE ON DELETE RESTRICT;

--
-- Name: ref_antennas_devicetypes; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY antennas
    ADD CONSTRAINT ref_antennas_devicetypes FOREIGN KEY (antennatype_id) REFERENCES antennatypes(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ref_radios_devices; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY radios
    ADD CONSTRAINT ref_radios_devices FOREIGN KEY (device_id) REFERENCES devices(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ref_antennas_radios; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY antennas
    ADD CONSTRAINT ref_antennas_radios FOREIGN KEY (radio_id) REFERENCES radios(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ref_nodes_zones; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY nodes
    ADD CONSTRAINT ref_nodes_zones FOREIGN KEY (zone_id) REFERENCES zones(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ref_nodes_addresses; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY nodes
    ADD CONSTRAINT ref_nodes_addresses FOREIGN KEY (address_id) REFERENCES addresses(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ref_nodes_person_admin_c; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY nodes
    ADD CONSTRAINT ref_nodes_person_admin_c FOREIGN KEY (admin_c_id) REFERENCES person(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ref_nodes_person_tech_c; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY nodes
    ADD CONSTRAINT ref_nodes_person_tech_c FOREIGN KEY (tech_c_id) REFERENCES person(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ref_nodes_devices; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY devices
    ADD CONSTRAINT ref_nodes_devices FOREIGN KEY (node_id) REFERENCES nodes(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ref_devices_devicetypes; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY devices
    ADD CONSTRAINT ref_devices_devicetypes FOREIGN KEY (devicetype_id) REFERENCES devicetypes(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ref_devices_versions; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY devices
    ADD CONSTRAINT ref_devices_versions FOREIGN KEY (runs_version_id) REFERENCES versions(id) ON UPDATE CASCADE ON DELETE RESTRICT;



--
-- Name: ref_interfaces2logrecords_interfaces1; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY interfaces2logrecords
    ADD CONSTRAINT ref_interfaces2logrecords_interfaces1 FOREIGN KEY (interface_id) REFERENCES interfaces(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ref_interfaces2logrecords_interfaces2; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY interfaces2logrecords
    ADD CONSTRAINT ref_interfaces2logrecords_interfaces2 FOREIGN KEY (otherinterface_id) REFERENCES interfaces(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ref_interfaces2logrecords_logrecords; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY interfaces2logrecords
    ADD CONSTRAINT ref_interfaces2logrecords_logrecords FOREIGN KEY (logrecord_id) REFERENCES logrecords(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ref_interfaces_devices; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY interfaces
    ADD CONSTRAINT ref_interfaces_devices FOREIGN KEY (device_id) REFERENCES devices(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ref_interfaces_devicetypes; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY interfaces
    ADD CONSTRAINT ref_interfaces_devicetypes FOREIGN KEY (interfacetype_id) REFERENCES devicetypes(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ref_ips_interfaces; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY ips
    ADD CONSTRAINT ref_ips_interfaces FOREIGN KEY (interface_id) REFERENCES antennas(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ref_locationlogs_devices; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY locationlogs
    ADD CONSTRAINT ref_locationlogs_devices FOREIGN KEY (device_id) REFERENCES devices(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ref_roles2person_person; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY roles2person
    ADD CONSTRAINT ref_roles2person_person FOREIGN KEY (person_id) REFERENCES person(id) ON UPDATE CASCADE ;


--
-- Name: ref_person2person_mentor; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY person
    ADD CONSTRAINT ref_person2person_mentor FOREIGN KEY ( mentor_person_id) REFERENCES person(id) ON UPDATE CASCADE ;


--
-- Name: ref_roles2person_roles; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY roles2person
    ADD CONSTRAINT ref_roles2person_roles FOREIGN KEY (privilege_id) REFERENCES roles(id) ON UPDATE CASCADE ;


--
-- Name: ref_sensors2logrecords_sensors; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY sensors2logrecords
    ADD CONSTRAINT ref_sensors2logrecords_sensors FOREIGN KEY (sensor_id) REFERENCES sensors(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ref_sensors_devices; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY sensors
    ADD CONSTRAINT ref_sensors_devices FOREIGN KEY (device_id) REFERENCES devices(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ref_sensors_devicetypes; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY sensors
    ADD CONSTRAINT ref_sensors_devicetypes FOREIGN KEY (sensortype_id) REFERENCES devicetypes(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ref_services_ips; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY services
    ADD CONSTRAINT ref_services_ips FOREIGN KEY (ip_id) REFERENCES ips(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ref_updates_version_from; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY updates
    ADD CONSTRAINT ref_updates_version_from FOREIGN KEY (fromversion) REFERENCES versions(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ref_updates_versions_to; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY updates
    ADD CONSTRAINT ref_updates_versions_to FOREIGN KEY (toversion) REFERENCES versions(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: reg_sensors2logrecords_logrecords; Type: FK CONSTRAINT; Schema: implementation; Owner: developers
--

ALTER TABLE ONLY sensors2logrecords
    ADD CONSTRAINT reg_sensors2logrecords_logrecords FOREIGN KEY (logrecord_id) REFERENCES logrecords(id) ON UPDATE CASCADE ON DELETE RESTRICT;


-- Syntax:
-- CREATE [ OR REPLACE ] FUNCTION
--     name ( [ [ argmode ] [ argname ] argtype [, ...] ] )
--     [ RETURNS rettype ]
--   { LANGUAGE langname
--     | IMMUTABLE | STABLE | VOLATILE
--     | CALLED ON NULL INPUT | RETURNS NULL ON NULL INPUT | STRICT
--     | [ EXTERNAL ] SECURITY INVOKER | [ EXTERNAL ] SECURITY DEFINER
--     | COST execution_cost
--     | ROWS result_rows
--     | SET configuration_parameter { TO value | = value | FROM CURRENT }
--     | AS 'definition'
--     | AS 'obj_file', 'link_symbol'
--   } ...
--     [ WITH ( attribute [, ...] ) ]


-- COMMENT: we can now - based on this trigger mechanism copy away any historical data (trigger on update/delete) to a 
-- backup copy of each table... in case we need to
create or replace function implementation.changed ( ) RETURNS "trigger" LANGUAGE plpgsql VOLATILE CALLED ON NULL INPUT  SECURITY INVOKER AS '
BEGIN
  NEW.changed := NOW();
  RETURN NEW;
END;
';

create or replace function implementation.created ( ) RETURNS "trigger" LANGUAGE plpgsql VOLATILE CALLED ON NULL INPUT  SECURITY INVOKER AS '
BEGIN
  NEW.created := NOW();
  RETURN NEW;
END;
';


CREATE TRIGGER changed BEFORE UPDATE ON standardtable FOR EACH ROW EXECUTE PROCEDURE changed()	;
CREATE TRIGGER created BEFORE INSERT ON standardtable FOR EACH ROW EXECUTE PROCEDURE created()	;
CREATE TRIGGER changed BEFORE UPDATE ON addresses FOR EACH ROW EXECUTE PROCEDURE changed()	;
CREATE TRIGGER created BEFORE INSERT ON addresses FOR EACH ROW EXECUTE PROCEDURE created()	;
CREATE TRIGGER changed BEFORE UPDATE ON antennas FOR EACH ROW EXECUTE PROCEDURE changed()	;
CREATE TRIGGER created BEFORE INSERT ON antennas FOR EACH ROW EXECUTE PROCEDURE created()	;
CREATE TRIGGER changed BEFORE UPDATE ON devices FOR EACH ROW EXECUTE PROCEDURE changed()	;
CREATE TRIGGER created BEFORE INSERT ON devices FOR EACH ROW EXECUTE PROCEDURE created()	;
CREATE TRIGGER changed BEFORE UPDATE ON devicetypes FOR EACH ROW EXECUTE PROCEDURE changed()	;
CREATE TRIGGER created BEFORE INSERT ON devicetypes FOR EACH ROW EXECUTE PROCEDURE created()	;
CREATE TRIGGER changed BEFORE UPDATE ON zones FOR EACH ROW EXECUTE PROCEDURE changed()	;
CREATE TRIGGER created BEFORE INSERT ON zones FOR EACH ROW EXECUTE PROCEDURE created()	;
CREATE TRIGGER changed BEFORE UPDATE ON manufacturers FOR EACH ROW EXECUTE PROCEDURE changed()	;
CREATE TRIGGER created BEFORE INSERT ON manufacturers FOR EACH ROW EXECUTE PROCEDURE created()	;
CREATE TRIGGER changed BEFORE UPDATE ON antennatypes FOR EACH ROW EXECUTE PROCEDURE changed()	;
CREATE TRIGGER created BEFORE INSERT ON antennatypes FOR EACH ROW EXECUTE PROCEDURE created()	;
CREATE TRIGGER changed BEFORE UPDATE ON interfaces FOR EACH ROW EXECUTE PROCEDURE changed()	;
CREATE TRIGGER created BEFORE INSERT ON interfaces FOR EACH ROW EXECUTE PROCEDURE created()	;
CREATE TRIGGER changed BEFORE UPDATE ON nodes FOR EACH ROW EXECUTE PROCEDURE changed()	;
CREATE TRIGGER created BEFORE INSERT ON nodes FOR EACH ROW EXECUTE PROCEDURE created()	;
CREATE TRIGGER changed BEFORE UPDATE ON radios FOR EACH ROW EXECUTE PROCEDURE changed()	;
CREATE TRIGGER created BEFORE INSERT ON radios FOR EACH ROW EXECUTE PROCEDURE created()	;
CREATE TRIGGER changed BEFORE UPDATE ON interfaces2logrecords FOR EACH ROW EXECUTE PROCEDURE changed()	;
CREATE TRIGGER created BEFORE INSERT ON interfaces2logrecords FOR EACH ROW EXECUTE PROCEDURE created()	;
CREATE TRIGGER changed BEFORE UPDATE ON ips FOR EACH ROW EXECUTE PROCEDURE changed()	;
CREATE TRIGGER created BEFORE INSERT ON ips FOR EACH ROW EXECUTE PROCEDURE created()	;
CREATE TRIGGER changed BEFORE UPDATE ON locationlogs FOR EACH ROW EXECUTE PROCEDURE changed()	;
CREATE TRIGGER created BEFORE INSERT ON locationlogs FOR EACH ROW EXECUTE PROCEDURE created()	;
CREATE TRIGGER changed BEFORE UPDATE ON logrecords FOR EACH ROW EXECUTE PROCEDURE changed()	;
CREATE TRIGGER created BEFORE INSERT ON logrecords FOR EACH ROW EXECUTE PROCEDURE created()	;
CREATE TRIGGER changed BEFORE UPDATE ON person FOR EACH ROW EXECUTE PROCEDURE changed()	;
CREATE TRIGGER created BEFORE INSERT ON person FOR EACH ROW EXECUTE PROCEDURE created()	;
CREATE TRIGGER changed BEFORE UPDATE ON roles FOR EACH ROW EXECUTE PROCEDURE changed()	;
CREATE TRIGGER created BEFORE INSERT ON roles FOR EACH ROW EXECUTE PROCEDURE created()	;
CREATE TRIGGER changed BEFORE UPDATE ON roles2person FOR EACH ROW EXECUTE PROCEDURE changed()	;
CREATE TRIGGER created BEFORE INSERT ON roles2person FOR EACH ROW EXECUTE PROCEDURE created()	;
CREATE TRIGGER changed BEFORE UPDATE ON sensors FOR EACH ROW EXECUTE PROCEDURE changed()	;
CREATE TRIGGER created BEFORE INSERT ON sensors FOR EACH ROW EXECUTE PROCEDURE created()	;
CREATE TRIGGER changed BEFORE UPDATE ON sensors2logrecords FOR EACH ROW EXECUTE PROCEDURE changed()	;
CREATE TRIGGER created BEFORE INSERT ON sensors2logrecords FOR EACH ROW EXECUTE PROCEDURE created()	;
CREATE TRIGGER changed BEFORE UPDATE ON services FOR EACH ROW EXECUTE PROCEDURE changed()	;
CREATE TRIGGER created BEFORE INSERT ON services FOR EACH ROW EXECUTE PROCEDURE created()	;
CREATE TRIGGER changed BEFORE UPDATE ON updates FOR EACH ROW EXECUTE PROCEDURE changed()	;
CREATE TRIGGER created BEFORE INSERT ON updates FOR EACH ROW EXECUTE PROCEDURE created()	;
CREATE TRIGGER changed BEFORE UPDATE ON versions FOR EACH ROW EXECUTE PROCEDURE changed()	;
CREATE TRIGGER created BEFORE INSERT ON versions FOR EACH ROW EXECUTE PROCEDURE created()	;
CREATE TRIGGER changed BEFORE UPDATE ON links FOR EACH ROW EXECUTE PROCEDURE changed()	;
CREATE TRIGGER created BEFORE INSERT ON links FOR EACH ROW EXECUTE PROCEDURE created()	;




-- 
-- views 
--

CREATE VIEW "v_device_manufacturers" AS SELECT "implementation"."devicetypes"."manual_url", "implementation"."devicetypes"."id", "implementation"."devicetypes"."name" as devicetype_name, "implementation"."devicetypes"."model", "implementation"."devicetypes"."pic_url", "implementation"."devicetypes"."revision", "implementation"."manufacturers"."url", "implementation"."manufacturers"."name" as manufacturer_name FROM "implementation"."devicetypes" LEFT JOIN "implementation"."manufacturers" ON ("implementation"."devicetypes"."manufacturer_id" = "implementation"."manufacturers"."id")  ;




