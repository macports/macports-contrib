-- People represents a person, potentially with a login/password
-- persons are used for maintainer, submitter, commenter?
drop table if exists people;
create table people (
    id                bigint not null primary key auto_increment,
    
    user_name         varchar(63),
    first_name        varchar(63),
    last_name         varchar(63),
    email             varchar(63),
    
    auth_method       varchar(31),
    auth_token        varchar(255),
    
    public_key        text
);


-- Ports represents a port: a piece of software
drop table if exists ports;
create table ports (
    id                bigint not null primary key auto_increment,
    
    -- these fields are duplicated in port_pkgs
    name              varchar(63),
    short_desc        text,
    long_desc         text,
    home_page         varchar(255),
    
    index name_index(name)
    
    -- many-many association for tags through ports_tags
    -- many-many association for maintainers through ports_maintainers
);


-- ports_maintainers: many-many association between Maintainers and Ports
drop table if exists maintainers_ports;
create table maintainers_ports (
    person_id         bigint not null,
    port_id           bigint not null,
    
    index port_index(port_id),
    index person_index(person_id)
);


-- A PortPkg is an instance of build/install rules for a port.
-- There may be many PortPkg for each Port
drop table if exists port_pkgs;
create table port_pkgs (
    id                bigint not null primary key auto_increment,

    port_id           bigint not null,
    
    name              varchar(63),
    short_desc        text,
    long_desc         text,
    home_page         varchar(255),
    
    submitted_at      datetime not null,
    submitter_id      bigint not null, -- one-one: Person
    submitter_notes   text,
    
    epoch             varchar(32),
    version           varchar(32),
    revision          varchar(32),
    
    votes_for         int not null default 0,
    votes_against     int not null default 0,
    download_count    int not null default 0,
    
    index submitted_at_index(submitted_at),
    index submitter_index(submitter_id),
    index port_index(port_id)
);


-- Reference to a file
-- Currently only supports references from port_pkg, but could
-- be extended to support references from people (pictures?), etc.
drop table if exists file_refs;
create table file_refs (
    id                  bigint not null primary key auto_increment,
    file_info_id        bigint not null,
    port_pkg_id         bigint,     -- owned by port_pkg
    is_port_pkg         tinyint(1) not null default 0,
    download_count      int not null default 0,
    
    index file_index(file_info_id),
    index port_pkg_index(port_pkg_id)
);

  
-- FileInfo: main representation of a file, referenced
-- by other tables through FileRef, with data stored
-- in one or more FileBlob.
drop table if exists file_infos;
create table file_infos (
    id                  bigint not null primary key auto_increment,
    file_path           varchar(2047),
    length              bigint not null,
    mime_type           varchar(63),
    md5                 varchar(32),
    sha256              varchar(64),

    index info_index(file_path(64), md5, sha256)
);


drop table if exists file_blobs;
create table file_blobs (
    id                  bigint not null primary key auto_increment,
    file_info_id        bigint not null,
    sequence            int not null,
    data                blob,
    
    index file_index(file_info_id, sequence)
);


-- A tag which may be attached to various items through Ports_Tags, Port_Pkgs_Tags
drop table if exists tags;
create table tags (
    id                  bigint not null primary key auto_increment,
    name                varchar(31),
    
    index name_index(name)
);

       
-- many-many relationship between PortPkg and Tag
drop table if exists port_pkgs_tags;
create table port_pkgs_tags (
    port_pkg_id         bigint not null,
    tag_id              bigint not null,
    
    primary key (port_pkg_id, tag_id),
    index tag_index(tag_id)
);



-- many-many relationship between Port and Tag
drop table if exists ports_tags;
create table ports_tags (
    port_id             bigint not null,
    tag_id              bigint not null,
    
    primary key (port_id, tag_id),
    index tag_index(tag_id)
);


-- Variant available to a PortPkg
drop table if exists variants;
create table variants (
    id                  bigint not null primary key auto_increment,
    port_pkg_id         bigint not null,
    
    name                varchar(63),
    description         text,
    
    index port_pkg_index(port_pkg_id)
    
    -- conflicts expr?
);


-- A dependency onto another port (not complete)
drop table if exists dependencies;
create table dependencies (
    id                  bigint not null primary key auto_increment,
    expression          text                -- textual? dependency expression
    
    -- can we point directly to the target port (or portpkg, or porturl???)
    -- that would make it much easier to determine reverse dependencies.
    -- maybe we have nullable fields for port, portpkg, porturl, version, revision, etc...
);


-- many-one relationship from Dependency to PortPkg
drop table if exists dependencies_port_pkgs;
create table dependencies_port_pkgs (
    package_id          bigint not null,
    dependency_id       bigint not null,
    
    primary key (package_id, dependency_id)
);

-- many-one relationship from Variant to Dependency
drop table if exists dependencies_variants;
create table dependencies_variants (
    variant_id          bigint not null,
    dependency_id       bigint not null,
    
    primary key (variant_id, dependency_id)
);


-- Human comments on ports and portpkgs
drop table if exists comments;
create table comments (
    id                  bigint not null primary key auto_increment,
    commenter_id        bigint not null, -- many-one: Person
    comment             text,
    comment_at          timestamp not null
);


-- many-one relationship from Comment to Port
drop table if exists comments_ports;
create table comments_ports (
    comment_id          bigint not null,
    port_id             bigint not null,
    
    primary key (comment_id, port_id)
);


-- many-one relationship from Comment to PortPkg
drop table if exists comments_port_pkgs;
create table comments_port_pkgs (
    comment_id          bigint not null,
    port_pkg_id         bigint not null,
    
    primary key (comment_id, port_pkg_id)
);


-- Status reports on port_pkgs, perhaps machine submitted
drop table if exists status_reports;
create table status_reports (
    id                  bigint not null primary key auto_increment,
    reporter_id         bigint not null, -- many-one: Person
    report_type         int,
    status              int,
    report              text,
    report_at           timestamp not null
);


-- many-one relationship from Status_Report to Port_Pkg
drop table if exists status_reports_port_pkgs;
create table status_reports_port_pkgs (
    status_report_id    bigint not null,
    port_pkg_id         bigint not null,
    
    primary key (status_report_id, port_pkg_id)
);


-- general purpose token
drop table if exists tokens;
create table tokens (
    id                  bigint not null primary key auto_increment,
    random              bigint not null,
    expires             datetime,
    data                text,
    type                varchar(15)
);


-- Missing components:
-- ==================================
