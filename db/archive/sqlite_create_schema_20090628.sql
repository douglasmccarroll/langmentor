CREATE TABLE user (
  user_id INT UNSIGNED NOT NULL ,
  given_name VARCHAR(100) NOT NULL,
  family_name VARCHAR(100) NOT NULL,
  screen_name VARCHAR(100) NOT NULL,
  native_language_id SMALLINT UNSIGNED NOT NULL,
  target_language_id SMALLINT UNSIGNED NOT NULL,
  email VARCHAR(200) NOT NULL,
  sex VARCHAR(1) NOT NULL,
  dob VARCHAR(19),
  premium_subscription BOOL,
  average_user_quality_feedback_given FLOAT UNSIGNED,
  most_recent_server_generated_sync_number MEDIUMINT NOT NULL,
  PRIMARY KEY (user_id)
)  ;

CREATE TABLE category (
  category_id SMALLINT UNSIGNED NOT NULL ,
  en_us_name VARCHAR(45) NOT NULL,
  PRIMARY KEY (category_id)
)  ;

CREATE TABLE language (
  language_id SMALLINT UNSIGNED NOT NULL ,
  abbreviation VARCHAR(10) NOT NULL,
  en_us_name VARCHAR(100) NOT NULL,
  en_us_example VARCHAR(100) NOT NULL,
  PRIMARY KEY (language_id)
)  ;

CREATE TABLE learning_feedback (
  learning_feedback_id SMALLINT UNSIGNED NOT NULL ,
  abbreviation VARCHAR(20) NOT NULL,
  en_us_name VARCHAR(50) NOT NULL,
  PRIMARY KEY (learning_feedback_id)
)  ;

CREATE TABLE learning_mode (
  learning_mode_id SMALLINT UNSIGNED NOT NULL ,
  token VARCHAR(100) NOT NULL,
  en_us_name VARCHAR(100) NOT NULL,
  order_level TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (learning_mode_id)
)  ;

CREATE TABLE level (
  level_id SMALLINT UNSIGNED NOT NULL ,
  en_us_name VARCHAR(50) NOT NULL,
  order_level TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (level_id)
)  ;

CREATE TABLE uber_module (
  uber_module_id MEDIUMINT UNSIGNED NOT NULL ,
  native_language_id SMALLINT UNSIGNED NOT NULL,
  target_language_id SMALLINT UNSIGNED NOT NULL,
  most_recent_module_version_creation_date_time VARCHAR(19) NOT NULL,
  PRIMARY KEY (uber_module_id),
  FOREIGN KEY (native_language_id) REFERENCES language(language_id),
  FOREIGN KEY (target_language_id) REFERENCES language(language_id)
)  ;
  
CREATE INDEX idx_uber_module__native_language_id ON uber_module (native_language_id);
CREATE INDEX idx_uber_module__target_language_id ON uber_module (target_language_id);

CREATE TABLE module_version (
  module_version_id MEDIUMINT UNSIGNED NOT NULL ,
  uber_module_id MEDIUMINT UNSIGNED NOT NULL,
  category_id SMALLINT UNSIGNED NOT NULL,
  level_id SMALLINT UNSIGNED NOT NULL,
  native_language_name VARCHAR(50) NOT NULL,
  target_language_name VARCHAR(50) NOT NULL,
  folder_name VARCHAR(50) NOT NULL,
  premium BOOL,
  module_version_creation_date_time VARCHAR(19) NOT NULL,
  xml_file_size INT UNSIGNED,
  assets_file_size INT UNSIGNED,
  PRIMARY KEY (module_version_id),
  FOREIGN KEY (uber_module_id) REFERENCES uber_module(uber_module_id),
  FOREIGN KEY (category_id) REFERENCES category(category_id),
  FOREIGN KEY (level_id) REFERENCES level(level_id)
)  ;

CREATE INDEX idx_module_version__uber_module_id ON module_version (uber_module_id);
CREATE INDEX idx_module_version__category_id ON module_version (category_id);
CREATE INDEX idx_module_version__level_id ON module_version (level_id);

CREATE TABLE chunk (
  chunk_id MEDIUMINT UNSIGNED NOT NULL ,
  module_version_id MEDIUMINT UNSIGNED NOT NULL,
  uber_module_creation_date_time VARCHAR(19) NOT NULL,
  order_level TINYINT UNSIGNED NOT NULL,
  target_audio_duration MEDIUMINT UNSIGNED NOT NULL,
  PRIMARY KEY (chunk_id),
  FOREIGN KEY (module_version_id) REFERENCES module_version(module_version_id),
  FOREIGN KEY (module_version_id) REFERENCES module_version(module_version_id)
)  ;

CREATE INDEX idx_chunk__module_version_id ON chunk (module_version_id);

CREATE TABLE module_version_consumption (
  module_version_consumption_id BIGINT UNSIGNED NOT NULL ,
  user_id INT UNSIGNED NOT NULL,
  module_version_id MEDIUMINT UNSIGNED NOT NULL,
  date_time VARCHAR(19) NOT NULL,
  seconds_consumed SMALLINT NOT NULL,
  learning_mode_id SMALLINT UNSIGNED NOT NULL,
  uploaded BOOL,
  PRIMARY KEY (module_version_consumption_id),
  FOREIGN KEY (user_id) REFERENCES user(user_id),
  FOREIGN KEY (module_version_id) REFERENCES module_version(module_version_id),
  FOREIGN KEY (learning_mode_id) REFERENCES learning_mode(learning_mode_id)
)  ;

CREATE INDEX idx_module_version_consumption__module_version_id ON module_version_consumption (module_version_id);
CREATE INDEX idx_module_version_consumption__user_id ON module_version_consumption (user_id);
CREATE INDEX idx_module_version_consumption__uploaded ON module_version_consumption (uploaded);

CREATE TABLE module_version_contribution (
  module_version_contribution_id INT UNSIGNED NOT NULL ,
  user_id INT UNSIGNED NOT NULL,
  module_version_id MEDIUMINT UNSIGNED NOT NULL,
  percentage_contributed FLOAT UNSIGNED NOT NULL,
  PRIMARY KEY (module_version_contribution_id),
  FOREIGN KEY (user_id) REFERENCES user(user_id),
  FOREIGN KEY (module_version_id) REFERENCES module_version(module_version_id)
)  ;

CREATE INDEX idx_module_version_contribution__module_version_id ON module_version_contribution (module_version_id);
CREATE INDEX idx_module_version_contribution__user_id ON module_version_contribution (user_id);

CREATE TABLE quality_feedback (
  quality_feedback_id SMALLINT UNSIGNED NOT NULL ,
  en_us_name VARCHAR(100) NOT NULL,
  PRIMARY KEY (quality_feedback_id)
)  ;

CREATE TABLE user_security (
  user_id INT UNSIGNED NOT NULL,
  password VARCHAR(20) NOT NULL,
  PRIMARY KEY (user_id),
  FOREIGN KEY (user_id) REFERENCES user(user_id)
)  ;

CREATE TABLE user_learning_feedback (
  user_learning_feedback_id INT UNSIGNED NOT NULL ,
  module_version_id MEDIUMINT UNSIGNED NOT NULL,
  chunk_id MEDIUMINT UNSIGNED NOT NULL,
  uploaded BOOL,
  date_time VARCHAR(19) NOT NULL,
  learning_feedback_id SMALLINT UNSIGNED NOT NULL,
  learning_mode_id SMALLINT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (user_learning_feedback_id),
  FOREIGN KEY (user_id) REFERENCES user(user_id),
  FOREIGN KEY (chunk_id) REFERENCES chunk(chunk_id),
  FOREIGN KEY (module_version_id) REFERENCES module_version(module_version_id),
  FOREIGN KEY (learning_feedback_id) REFERENCES learning_feedback(learning_feedback_id)
)  ;

CREATE INDEX idx_user_learning_feedback__user_id ON user_learning_feedback (user_id);
CREATE INDEX idx_user_learning_feedback__chunk_id ON user_learning_feedback (chunk_id);
CREATE INDEX idx_user_learning_feedback__uploaded ON user_learning_feedback (uploaded);

CREATE TABLE user_quality_feedback (
  user_quality_feedback_id INT UNSIGNED NOT NULL ,
  user_id INT UNSIGNED NOT NULL,
  module_version_id MEDIUMINT UNSIGNED NOT NULL,
  date_time VARCHAR(19) NOT NULL,
  quality_feedback_id SMALLINT UNSIGNED NOT NULL,
  comments VARCHAR(2000),
  uploaded BOOL,
  PRIMARY KEY (user_quality_feedback_id),
  FOREIGN KEY (user_id) REFERENCES user(user_id),
  FOREIGN KEY (module_version_id) REFERENCES module_version(module_version_id),
  FOREIGN KEY (quality_feedback_id) REFERENCES quality_feedback(quality_feedback_id)
)  ;

CREATE INDEX idx_user_quality_feedback__user_id ON user_quality_feedback (user_id);
CREATE INDEX idx_user_quality_feedback__module_version_id ON user_quality_feedback (module_version_id);
CREATE INDEX idx_user_quality_feedback__uploaded ON user_quality_feedback (uploaded);

CREATE TABLE user_module_version_link (
  user_module_version_link_id INT UNSIGNED NOT NULL ,
  user_id INT UNSIGNED NOT NULL,
  module_version_id MEDIUMINT UNSIGNED NOT NULL,
  PRIMARY KEY(user_module_version_link_id),
  FOREIGN KEY (user_id) REFERENCES user(user_id),
  FOREIGN KEY (module_version_id) REFERENCES module_version(module_version_id)
)  ;

CREATE INDEX idx_user_module_version_link__user_id ON user_module_version_link (user_id);
