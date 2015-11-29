CREATE TABLE content_provider_account (
  content_provider_account_id INT UNSIGNED NOT NULL,
  content_provider_uri VARCHAR(500) NOT NULL,
  user_name VARCHAR(100) NOT NULL,
  encrypted_password VARCHAR(50) NOT NULL,
  PRIMARY KEY (content_provider_account_id)
)  ;

CREATE INDEX idx_content_provider_account__content_provider_uri ON content_provider_account (content_provider_uri);

CREATE TABLE language (
  language_id SMALLINT UNSIGNED NOT NULL,
  abbreviation VARCHAR(10) NOT NULL,
  en_us_name VARCHAR(100) NOT NULL,
  en_us_example VARCHAR(100) NOT NULL,
  PRIMARY KEY (language_id)
)  ;

CREATE TABLE learning_feedback (
  learning_feedback_id SMALLINT UNSIGNED NOT NULL,
  abbreviation VARCHAR(20) NOT NULL,
  en_us_name VARCHAR(50) NOT NULL,
  location_in_order TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (learning_feedback_id)
)  ;

CREATE TABLE learning_mode (
  learning_mode_id SMALLINT UNSIGNED NOT NULL,
  token VARCHAR(100) NOT NULL,
  en_us_name VARCHAR(100) NOT NULL,
  location_in_order TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (learning_mode_id)
)  ;

CREATE TABLE level (
  level_id SMALLINT UNSIGNED NOT NULL,
  en_us_name VARCHAR(50) NOT NULL,
  location_in_order TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (level_id)
)  ;

CREATE TABLE quality_feedback (
  quality_feedback_id SMALLINT UNSIGNED NOT NULL ,
  en_us_name VARCHAR(100) NOT NULL,
  location_in_order TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (quality_feedback_id)
)  ;

CREATE TABLE module_version (
  module_version_id MEDIUMINT UNSIGNED NOT NULL,
  module_version_signature INT UNSIGNED,
  content_provider_uri VARCHAR(500) NOT NULL,
  published_module_version_id VARCHAR(100),
  level_id SMALLINT UNSIGNED NOT NULL,
  native_language_id SMALLINT UNSIGNED NOT NULL,
  target_language_id SMALLINT UNSIGNED NOT NULL,
  native_language_name VARCHAR(50) NOT NULL,
  target_language_name VARCHAR(50) NOT NULL,
  paid_content BOOL,
  xml_file_size INT UNSIGNED,
  assets_file_size INT UNSIGNED,
  uploaded BOOL,
  PRIMARY KEY (module_version_id),
  FOREIGN KEY (level_id) REFERENCES level(level_id)
  FOREIGN KEY (native_language_id) REFERENCES language(language_id)
  FOREIGN KEY (target_language_id) REFERENCES language(language_id)
)  ;

CREATE INDEX idx_module_version__module_version_signature ON module_version (module_version_signature);
CREATE INDEX idx_module_version__content_provider_uri ON module_version (content_provider_uri);
CREATE INDEX idx_module_version__level_id ON module_version (level_id);
CREATE INDEX idx_module_version__native_language_id ON module_version (native_language_id);
CREATE INDEX idx_module_version__target_language_id ON module_version (target_language_id);
CREATE INDEX idx_module_version__uploaded ON module_version (uploaded);

CREATE TABLE module_version_consumption (
  module_version_consumption_id BIGINT UNSIGNED NOT NULL ,
  module_version_id MEDIUMINT UNSIGNED NOT NULL,
  module_version_signature INT UNSIGNED NOT NULL,
  content_provider_uri VARCHAR(500) NOT NULL,
  date_time VARCHAR(19) NOT NULL,
  seconds_consumed SMALLINT NOT NULL,
  learning_mode_id SMALLINT UNSIGNED NOT NULL,
  uploaded BOOL,
  PRIMARY KEY (module_version_consumption_id),
  FOREIGN KEY (module_version_id) REFERENCES module_version(module_version_id),
  FOREIGN KEY (learning_mode_id) REFERENCES learning_mode(learning_mode_id)
)  ;

CREATE INDEX idx_module_version_consumption__module_version_id ON module_version_consumption (module_version_id);
CREATE INDEX idx_module_version_consumption__module_version_signature ON module_version_consumption (module_version_signature);
CREATE INDEX idx_module_version_consumption__content_provider_uri ON module_version_consumption (content_provider_uri);
CREATE INDEX idx_module_version_consumption__uploaded ON module_version_consumption (uploaded);

CREATE TABLE module_version_contribution (
  module_version_contribution_id INT UNSIGNED NOT NULL,
  module_version_id MEDIUMINT UNSIGNED NOT NULL,
  contributor_display_name VARCHAR(100) NOT NULL,
  contributor_url VARCHAR(200),
  description VARCHAR(1000),
  percentage_contributed FLOAT UNSIGNED NOT NULL,
  PRIMARY KEY (module_version_contribution_id),
  FOREIGN KEY (module_version_id) REFERENCES module_version(module_version_id)
)  ;

CREATE INDEX idx_module_version_contribution__module_version_id ON module_version_contribution (module_version_id);

CREATE TABLE module_version_quality_feedback (
  module_version_quality_feedback_id INT UNSIGNED NOT NULL,
  module_version_id MEDIUMINT UNSIGNED NOT NULL,
  module_version_signature INT UNSIGNED NOT NULL,
  content_provider_uri VARCHAR(500) NOT NULL,
  date_time VARCHAR(19) NOT NULL,
  quality_feedback_id SMALLINT UNSIGNED NOT NULL,
  comments VARCHAR(2000),
  uploaded BOOL,
  PRIMARY KEY (module_version_quality_feedback_id),
  FOREIGN KEY (module_version_id) REFERENCES module_version(module_version_id),
  FOREIGN KEY (quality_feedback_id) REFERENCES quality_feedback(quality_feedback_id)
)  ;

CREATE INDEX idx_user_quality_feedback__module_version_id ON user_quality_feedback (module_version_id);
CREATE INDEX idx_user_quality_feedback__module_version_signature ON user_quality_feedback (module_version_signature);
CREATE INDEX idx_user_quality_feedback__content_provider_uri ON user_quality_feedback (content_provider_uri);
CREATE INDEX idx_user_quality_feedback__uploaded ON user_quality_feedback (uploaded);

CREATE TABLE module_version_tag (
  module_version_tag_id MEDIUMINT UNSIGNED NOT NULL,
  module_version_id MEDIUMINT UNSIGNED NOT NULL,
  module_version_signature INT UNSIGNED NOT NULL,
  content_provider_uri VARCHAR(500) NOT NULL,
  tag VARCHAR(100) NOT NULL,
  tag_language_id SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (module_version_tag_id),
  FOREIGN KEY (module_version_id) REFERENCES module_version(module_version_id)
) ;

CREATE INDEX idx_module_version_tag__module_version_id ON module_version_tag (module_version_id);
CREATE INDEX idx_module_version_tag__module_version_signature ON module_version_tag (module_version_signature);
CREATE INDEX idx_module_version_tag__content_provider_uri ON module_version_tag (content_provider_uri);

CREATE TABLE chunk (
  chunk_id MEDIUMINT UNSIGNED NOT NULL ,
  module_version_id MEDIUMINT UNSIGNED NOT NULL,
  module_version_signature INT UNSIGNED NOT NULL,
  content_provider_uri VARCHAR(500) NOT NULL,
  location_in_order TINYINT UNSIGNED NOT NULL,
  file_name_root VARCHAR(100) NOT NULL,
  PRIMARY KEY (chunk_id),
  FOREIGN KEY (module_version_id) REFERENCES module_version(module_version_id)
)  ;

CREATE INDEX idx_chunk__module_version_id ON chunk (module_version_id);
CREATE INDEX idx_chunk__module_version_signature ON chunk (module_version_signature);
CREATE INDEX idx_chunk__content_provider_uri ON chunk (content_provider_uri);

CREATE TABLE chunk_learning_feedback (
  chunk_learning_feedback_id INT UNSIGNED NOT NULL,
  module_version_id MEDIUMINT UNSIGNED NOT NULL,
  module_version_signature INT UNSIGNED NOT NULL,
  content_provider_uri VARCHAR(500) NOT NULL,
  chunk_id MEDIUMINT UNSIGNED NOT NULL,
  chunk_location_in_order TINYINT UNSIGNED NOT NULL,
  uploaded BOOL,
  date_time VARCHAR(19) NOT NULL,
  learning_feedback_id SMALLINT UNSIGNED NOT NULL,
  learning_mode_id SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (chunk_learning_feedback_id),
  FOREIGN KEY (chunk_id) REFERENCES chunk(chunk_id),
  FOREIGN KEY (module_version_id) REFERENCES module_version(module_version_id),
  FOREIGN KEY (learning_feedback_id) REFERENCES learning_feedback(learning_feedback_id)
)  ;

CREATE INDEX idx_user_learning_feedback__chunk_id ON user_learning_feedback (chunk_id);
CREATE INDEX idx_user_learning_feedback__uploaded ON user_learning_feedback (uploaded);























