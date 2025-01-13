-- projects テーブル
create table if not exists projects
(
    id           integer primary key,
    project_name text
);

-- metadata テーブル
create table if not exists metadata
(
    id           integer primary key,
    project_id   integer,
    project_name text,
    author       text,
    licence      text,
    foreign key (project_id) references projects (id)
);

create table if not exists bubble_view_constraints
(
    id            integer primary key,
    project_id    integer,
    click_limit   integer,
    buble_radius  real,
    bubble_amount real,
    foreign key (project_id) references projects (id)
);

-- project_labels テーブル
create table if not exists project_labels
(
    id         integer primary key,
    project_id integer,
    name       text,
    foreign key (project_id) references projects (id)
);

-- annotations テーブル
create table if not exists annotations
(
    id         integer primary key,
    project_id integer,
    image      blob not null,
    foreign key (project_id) references projects (id)
);

-- key_points テーブル
create table if not exists key_points
(
    id            integer primary key,
    annotation_id integer,
    x             real,
    y             real,
    foreign key (annotation_id) references annotations (id)
);

-- click_points テーブル
create table if not exists click_points
(
    id            integer primary key,
    annotation_id integer,
    x             real,
    y             real,
    radius        real,
    foreign key (annotation_id) references annotations (id)
);

-- image_labels テーブル
create table if not exists image_labels
(
    id            integer primary key,
    annotation_id integer,
    name          text,
    foreign key (annotation_id) references annotations (id)
);

-- bounds テーブル
create table if not exists bounding_boxes
(
    id             integer primary key,
    start_x        real,
    start_y        real,
    end_x          real,
    end_y          real,
    annotation_id  integer,
    image_label_id integer,
    foreign key (annotation_id) references annotations (id),
    foreign key (image_label_id) references image_labels (id)
);
