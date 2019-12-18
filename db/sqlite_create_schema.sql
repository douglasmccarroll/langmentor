-- For comments, use "--" or "/*" and "*/"

-- To insert boolean values, use 0 for false, 1 for true

CREATE TABLE User (
  id INTEGER UNIQUE,
  nativeLanguageId INTEGER NOT NULL,
  targetLanguageId INTEGER NOT NULL
)  ;

-- For now, Libraries are only persisted when entered by the user.
-- Recommended libraries are specified in 'langcollab' info file(s) 
-- and are downloaded at each app startup.
-- Note that 'libraryId' is different from Library.id
-- libraryId and libraryName are obtained from the library XML file and are
-- persisted into LessonVersions and/or other data that are related to lesson versions

CREATE TABLE Library (
  enabled BOOL NOT NULL,
  libraryFolderURL TEXT
) ;

-- We always set hasRecommendedLibraries to 0 - this will be updated on app startup
CREATE TABLE Language (
  id INTEGER NOT NULL UNIQUE,
  iso639_3Code TEXT NOT NULL UNIQUE,
  hasRecommendedLibraries BOOL
)  ;

CREATE TABLE LanguageDisplayName (
  id INTEGER NOT NULL UNIQUE,
  languageId INTEGER NOT NULL,
  displayLanguageId INTEGER NOT NULL,
  displayName TEXT NOT NULL,
  displayNameAlphabetizable TEXT NOT NULL
)  ;

-- Mandarin Chinese
INSERT INTO Language VALUES ('1','cmn','0');
INSERT INTO LanguageDisplayName VALUES ('1','1','3','Mandarin Chinese','Chinese, Mandarin');
-- Spanish
INSERT INTO Language VALUES ('2','spa','0');
INSERT INTO LanguageDisplayName VALUES ('2','2','3','Spanish','Spanish');
-- English
INSERT INTO Language VALUES ('3','eng','0');
INSERT INTO LanguageDisplayName VALUES ('3','3','3','English','English');
-- Note: I'm using the term "Hindi" and the code "hin" here, but things aren't really this 
-- simple. See Wikipedia's Hindi-Urdu entry
-- Hindi
INSERT INTO Language VALUES ('4','hin','0');
INSERT INTO LanguageDisplayName VALUES ('4','4','3','Hindi','Hindi');
-- Arabic
INSERT INTO Language VALUES ('5','ara','0');
INSERT INTO LanguageDisplayName VALUES ('5','5','3','Arabic','Arabic');
-- Bengali
INSERT INTO Language VALUES ('6','ben','0');
INSERT INTO LanguageDisplayName VALUES ('6','6','3','Bengali','Bengali');
-- Portuguese
INSERT INTO Language VALUES ('7','por','0');
INSERT INTO LanguageDisplayName VALUES ('7','7','3','Portuguese','Portuguese');
-- Russian
INSERT INTO Language VALUES ('8','rus','0');
INSERT INTO LanguageDisplayName VALUES ('8','8','3','Russian','Russian');
-- Japanese
INSERT INTO Language VALUES ('9','jpn','0');
INSERT INTO LanguageDisplayName VALUES ('9','9','3','Japanese','Japanese');
-- Punjabi
INSERT INTO Language VALUES ('10','pnb','0');
INSERT INTO LanguageDisplayName VALUES ('10','10','3','Punjabi','Punjabi');
-- German
INSERT INTO Language VALUES ('11','deu','0');
INSERT INTO LanguageDisplayName VALUES ('11','11','3','German','German');
-- Javanese
INSERT INTO Language VALUES ('12','jav','0');
INSERT INTO LanguageDisplayName VALUES ('12','12','3','Javanese','Javanese');
-- Wu (Shanghainese)
INSERT INTO Language VALUES ('13','wuu','0');
INSERT INTO LanguageDisplayName VALUES ('13','13','3','Shanghainese','Shanghainese');
-- Marathi
INSERT INTO Language VALUES ('14','mar','0');
INSERT INTO LanguageDisplayName VALUES ('14','14','3','Marathi','Marathi');
-- Telugu
INSERT INTO Language VALUES ('15','tel','0');
INSERT INTO LanguageDisplayName VALUES ('15','15','3','Telugu','Telugu');
-- Vietnamese
INSERT INTO Language VALUES ('16','vie','0');
INSERT INTO LanguageDisplayName VALUES ('16','16','3','Vietnamese','Vietnamese');
-- French
INSERT INTO Language VALUES ('17','fra','0');
INSERT INTO LanguageDisplayName VALUES ('17','17','3','French','French');
-- Korean
INSERT INTO Language VALUES ('18','kor','0');
INSERT INTO LanguageDisplayName VALUES ('18','18','3','Korean','Korean');
-- Tamil
INSERT INTO Language VALUES ('19','tam','0');
INSERT INTO LanguageDisplayName VALUES ('19','19','3','Tamil','Tamil');
-- Cantonese
INSERT INTO Language VALUES ('20','yue','0');
INSERT INTO LanguageDisplayName VALUES ('20','20','3','Cantonese','Cantonese');
-- Turkish
INSERT INTO Language VALUES ('21','tur','0');
INSERT INTO LanguageDisplayName VALUES ('21','21','3','Turkish','Turkish');
-- Pashto
INSERT INTO Language VALUES ('22','pus','0');
INSERT INTO LanguageDisplayName VALUES ('22','22','3','Pashto','Pashto');
-- Italian
INSERT INTO Language VALUES ('23','ita','0');
INSERT INTO LanguageDisplayName VALUES ('23','23','3','Italian','Italian');
-- Taiwanese Hokkien
INSERT INTO Language VALUES ('24','nan','0');
INSERT INTO LanguageDisplayName VALUES ('24','24','3','Taiwanese Hokkien','Hokkien, Taiwanese');
-- Gujarati
INSERT INTO Language VALUES ('25','guj','0');
INSERT INTO LanguageDisplayName VALUES ('25','25','3','Gujarati','Gujarati');
-- Polish
INSERT INTO Language VALUES ('26','pol','0');
INSERT INTO LanguageDisplayName VALUES ('26','26','3','Polish','Polish');
-- Farsi
INSERT INTO Language VALUES ('27','pes','0');
INSERT INTO LanguageDisplayName VALUES ('27','27','3','Farsi','Farsi');
-- Bhojpuri
INSERT INTO Language VALUES ('28','bho','0');
INSERT INTO LanguageDisplayName VALUES ('28','28','3','Bhojpuri','Bhojpuri');
-- Awadhi
--INSERT INTO Language VALUES ('29','awa','0');
--INSERT INTO LanguageDisplayName VALUES ('29','29','3','Awadhi','Awadhi');
-- Ukrainian
INSERT INTO Language VALUES ('30','ukr','0');
INSERT INTO LanguageDisplayName VALUES ('30','30','3','Ukrainian','Ukrainian');
-- Indonesian
INSERT INTO Language VALUES ('31','ind','0');
INSERT INTO LanguageDisplayName VALUES ('31','31','3','Indonesian','Indonesian');
-- Xiang
INSERT INTO Language VALUES ('32','hsn','0');
INSERT INTO LanguageDisplayName VALUES ('32','32','3','Xiang','Xiang');
-- Malayalam
INSERT INTO Language VALUES ('33','mal','0');
INSERT INTO LanguageDisplayName VALUES ('33','33','3','Malayalam','Malayalam');
-- Kannada
INSERT INTO Language VALUES ('34','kan','0');
INSERT INTO LanguageDisplayName VALUES ('34','34','3','Kannada','Kannada');
-- Maithili
--INSERT INTO Language VALUES ('35','mai','0');
--INSERT INTO LanguageDisplayName VALUES ('35','35','3','Maithili','Maithili');
-- Sundanese
INSERT INTO Language VALUES ('36','sun','0');
INSERT INTO LanguageDisplayName VALUES ('36','36','3','Sundanese','Sundanese');
-- Burmese
INSERT INTO Language VALUES ('37','mya','0');
INSERT INTO LanguageDisplayName VALUES ('37','37','3','Burmese','Burmese');
-- Oriya
INSERT INTO Language VALUES ('38','ory','0');
INSERT INTO LanguageDisplayName VALUES ('38','38','3','Oriya','Oriya');
-- Marwari
--INSERT INTO Language VALUES ('39','mwr','0');
--INSERT INTO LanguageDisplayName VALUES ('39','39','3','Marwari','Marwari');
-- Hakka
INSERT INTO Language VALUES ('40','hak','0');
INSERT INTO LanguageDisplayName VALUES ('40','40','3','Hakka','Hakka');
-- Thai
INSERT INTO Language VALUES ('41','tha','0');
INSERT INTO LanguageDisplayName VALUES ('41','41','3','Thai','Thai');
-- Hausa
INSERT INTO Language VALUES ('42','hau','0');
INSERT INTO LanguageDisplayName VALUES ('42','42','3','Hausa','Hausa');
-- Tagalog (Filipino)
INSERT INTO Language VALUES ('43','tgl','0');
INSERT INTO LanguageDisplayName VALUES ('43','43','3','Tagalog (Filipino)','Tagalog (Filipino)');
-- Romanian
INSERT INTO Language VALUES ('44','ron','0');
INSERT INTO LanguageDisplayName VALUES ('44','44','3','Romanian','Romanian');
-- Dutch
INSERT INTO Language VALUES ('45','nld','0');
INSERT INTO LanguageDisplayName VALUES ('45','45','3','Dutch','Dutch');
-- Gan
INSERT INTO Language VALUES ('46','gan','0');
INSERT INTO LanguageDisplayName VALUES ('46','46','3','Gan','Gan');
-- Sindhi
INSERT INTO Language VALUES ('47','snd','0');
INSERT INTO LanguageDisplayName VALUES ('47','47','3','Sindhi','Sindhi');
-- Uzbek
INSERT INTO Language VALUES ('48','uzb','0');
INSERT INTO LanguageDisplayName VALUES ('48','48','3','Uzbek','Uzbek');
-- Azerbaijani
INSERT INTO Language VALUES ('49','aze','0');
INSERT INTO LanguageDisplayName VALUES ('49','49','3','Azerbaijani','Azerbaijani');
-- Rajasthani
--INSERT INTO Language VALUES ('50','raj','0');
--INSERT INTO LanguageDisplayName VALUES ('50','50','3','Rajasthani','Rajasthani');
-- Lao
INSERT INTO Language VALUES ('51','lao','0');
INSERT INTO LanguageDisplayName VALUES ('51','51','3','Lao','Lao');
-- Yoruba
INSERT INTO Language VALUES ('52','yor','0');
INSERT INTO LanguageDisplayName VALUES ('52','52','3','Yoruba','Yoruba');
-- Igbo
INSERT INTO Language VALUES ('53','ibo','0');
INSERT INTO LanguageDisplayName VALUES ('53','53','3','Igbo','Igbo');
-- Shilha
--INSERT INTO Language VALUES ('54','shi','0');
--INSERT INTO LanguageDisplayName VALUES ('54','54','3','Shilha','Shilha');
-- Amharic
INSERT INTO Language VALUES ('55','amh','0');
INSERT INTO LanguageDisplayName VALUES ('55','55','3','Amharic','Amharic');
-- Oromo
INSERT INTO Language VALUES ('56','orm','0');
INSERT INTO LanguageDisplayName VALUES ('56','56','3','Oromo','Oromo');
-- Chhattisgarhi
--INSERT INTO Language VALUES ('57','hne','0');
--INSERT INTO LanguageDisplayName VALUES ('57','57','3','Chhattisgarhi','Chhattisgarhi');
-- Assamese
INSERT INTO Language VALUES ('58','asm','0');
INSERT INTO LanguageDisplayName VALUES ('58','58','3','Assamese','Assamese');
-- Kurdish
INSERT INTO Language VALUES ('59','kur','0');
INSERT INTO LanguageDisplayName VALUES ('59','59','3','Kurdish','Kurdish');
-- Serbo-Croation
INSERT INTO Language VALUES ('60','hbs','0');
INSERT INTO LanguageDisplayName VALUES ('60','60','3','Serbo-Croation','Serbo-Croation');
-- Sinhalese
INSERT INTO Language VALUES ('61','sin','0');
INSERT INTO LanguageDisplayName VALUES ('61','61','3','Sinhala','Sinhala');
-- Cebuano
INSERT INTO Language VALUES ('62','ceb','0');
INSERT INTO LanguageDisplayName VALUES ('62','62','3','Cebuano','Cebuano');
-- Rangpuri
--INSERT INTO Language VALUES ('63','rkt','0');
--INSERT INTO LanguageDisplayName VALUES ('63','63','3','Rangpuri','Rangpuri');
-- Czech
INSERT INTO Language VALUES ('64','ces','0');
INSERT INTO LanguageDisplayName VALUES ('64','64','3','Czech','Czech');
-- Khmer, Central
INSERT INTO Language VALUES ('65','khm','0');
INSERT INTO LanguageDisplayName VALUES ('65','65','3','Central Khmer','Khmer, Central');
-- Sotho, Southern
INSERT INTO Language VALUES ('66','sot','0');
INSERT INTO LanguageDisplayName VALUES ('66','66','3','Southern Sotho','Sotho, Southern');
-- Nepali
INSERT INTO Language VALUES ('67','nep','0');
INSERT INTO LanguageDisplayName VALUES ('67','67','3','Nepali','Nepali');
-- Kinyarwanda
INSERT INTO Language VALUES ('68','kin','0');
INSERT INTO LanguageDisplayName VALUES ('68','68','3','Kinyarwanda','Kinyarwanda');
-- Somali
INSERT INTO Language VALUES ('69','som','0');
INSERT INTO LanguageDisplayName VALUES ('69','69','3','Somali','Somali');
-- Madurese
INSERT INTO Language VALUES ('70','mad','0');
INSERT INTO LanguageDisplayName VALUES ('70','70','3','Madurese','Madurese');
-- Haryanvi
INSERT INTO Language VALUES ('71','bgc','0');
INSERT INTO LanguageDisplayName VALUES ('71','71','3','Haryanvi','Haryanvi');
-- Pulaar
INSERT INTO Language VALUES ('72','fuc','0');
INSERT INTO LanguageDisplayName VALUES ('72','72','3','Pulaar','Pulaar');
-- Bavarian
INSERT INTO Language VALUES ('73','bar','0');
INSERT INTO LanguageDisplayName VALUES ('73','73','3','Bavarian','Bavarian');
-- Magahi
--INSERT INTO Language VALUES ('74','mag','0');
--INSERT INTO LanguageDisplayName VALUES ('74','74','3','Magahi','Magahi');
-- Greek
INSERT INTO Language VALUES ('75','ell','0');
INSERT INTO LanguageDisplayName VALUES ('75','75','3','Greek','Greek');
-- Chittagonian
--INSERT INTO Language VALUES ('76','ctg','0');
--INSERT INTO LanguageDisplayName VALUES ('76','76','3','Chittagonian','Chittagonian');
-- Deccan
--INSERT INTO Language VALUES ('77','dcc','0');
--INSERT INTO LanguageDisplayName VALUES ('77','77','3','Deccan','Deccan');
-- Hungarian
INSERT INTO Language VALUES ('78','hun','0');
INSERT INTO LanguageDisplayName VALUES ('78','78','3','Hungarian','Hungarian');
-- Catalan
INSERT INTO Language VALUES ('79','cat','0');
INSERT INTO LanguageDisplayName VALUES ('79','79','3','Catalan','Catalan');
-- Shona
INSERT INTO Language VALUES ('80','sna','0');
INSERT INTO LanguageDisplayName VALUES ('80','80','3','Shona','Shona');
-- Min Bei
--INSERT INTO Language VALUES ('81','mnp','0');
--INSERT INTO LanguageDisplayName VALUES ('81','81','3','Min Bei','Min Bei');
-- Zulu
INSERT INTO Language VALUES ('82','zul','0');
INSERT INTO LanguageDisplayName VALUES ('82','82','3','Zulu','Zulu');
-- Sylheti
--INSERT INTO Language VALUES ('83','syl','0');
--INSERT INTO LanguageDisplayName VALUES ('83','83','3','Sylheti','Sylheti');
-- Punjabi, Indian
INSERT INTO Language VALUES ('84','pan','0');
INSERT INTO LanguageDisplayName VALUES ('84','84','3','Indian Punjabi','Punjabi, Indian');
-- Malaysian
INSERT INTO Language VALUES ('85','zsm','0');
INSERT INTO LanguageDisplayName VALUES ('85','85','3','Malaysian','Malaysian');
-- Bulgarian
INSERT INTO Language VALUES ('86','bul','0');
INSERT INTO LanguageDisplayName VALUES ('86','86','3','Bulgarian','Bulgarian');
-- Min Dong
INSERT INTO Language VALUES ('87','cdo','0');
INSERT INTO LanguageDisplayName VALUES ('87','87','3','Min Dong','Min Dong');
-- Swedish
INSERT INTO Language VALUES ('88','swe','0');
INSERT INTO LanguageDisplayName VALUES ('88','88','3','Swedish','Swedish');
-- Haitian Creole
INSERT INTO Language VALUES ('89','hat','0');
INSERT INTO LanguageDisplayName VALUES ('89','89','3','Haitian Creole','Haitian Creole');
-- Estonian
INSERT INTO Language VALUES ('90','ekk','0');
INSERT INTO LanguageDisplayName VALUES ('90','90','3','Estonian','Estonian');
-- Lithuanian
INSERT INTO Language VALUES ('91','lit','0');
INSERT INTO LanguageDisplayName VALUES ('91','91','3','Lithuanian','Lithuanian');
-- Hebrew
INSERT INTO Language VALUES ('92','heb','0');
INSERT INTO LanguageDisplayName VALUES ('92','92','3','Hebrew','Hebrew');
-- Irish
INSERT INTO Language VALUES ('93','gle','0');
INSERT INTO LanguageDisplayName VALUES ('93','93','3','Irish','Irish');
-- Swahili
INSERT INTO Language VALUES ('94','swa','0');
INSERT INTO LanguageDisplayName VALUES ('94','94','3','Swahili','Swahili');
-- Yiddish
INSERT INTO Language VALUES ('95','yid','0');
INSERT INTO LanguageDisplayName VALUES ('95','95','3','Yiddish','Yiddish');
-- Klingon
INSERT INTO Language VALUES ('96','tlh','0');
INSERT INTO LanguageDisplayName VALUES ('96','96','3','Klingon','Klingon');
-- Esperanto
INSERT INTO Language VALUES ('97','epo','0');
INSERT INTO LanguageDisplayName VALUES ('97','97','3','Esperanto','Esperanto');
-- ccc
--INSERT INTO Language VALUES ('aaa','bbb','0');
--INSERT INTO LanguageDisplayName VALUES ('aaa','aaa','3','ccc','ccc');





CREATE TABLE LearningMode (
  id INTEGER NOT NULL UNIQUE,
  labelToken TEXT NOT NULL UNIQUE,
  locationInOrder INTEGER NOT NULL UNIQUE,
  isDualLanguage BOOL,
  hasRecordPlayback
)  ;

INSERT INTO LearningMode VALUES ('1', 'NativeTarget',           '1', '1', '0');
INSERT INTO LearningMode VALUES ('2', 'NativeTargetPause',      '2', '1', '1');
INSERT INTO LearningMode VALUES ('3', 'NativePauseTargetPause', '3', '1', '1');
INSERT INTO LearningMode VALUES ('4', 'Target',                 '4', '0', '0');
INSERT INTO LearningMode VALUES ('5', 'TargetPause',            '5', '0', '1');
INSERT INTO LearningMode VALUES ('6', 'TargetNative',           '6', '1', '0');
INSERT INTO LearningMode VALUES ('7', 'TargetPauseNative',      '7', '1', '0');
INSERT INTO LearningMode VALUES ('8', 'TargetPauseNativePause', '8', '1', '0');

CREATE TABLE Level (
  id INTEGER NOT NULL UNIQUE,
  labelToken TEXT NOT NULL UNIQUE,
  locationInOrder INTEGER NOT NULL UNIQUE
)  ;
INSERT INTO Level VALUES ('1', 'Introductory',        '1');
INSERT INTO Level VALUES ('2', 'Beginner',            '2');
INSERT INTO Level VALUES ('3', 'Beginner_Lower',      '3');
INSERT INTO Level VALUES ('4', 'Beginner_Middle',     '4');
INSERT INTO Level VALUES ('5', 'Beginner_Upper',      '5');
INSERT INTO Level VALUES ('6', 'Intermediate',        '6');
INSERT INTO Level VALUES ('7', 'Intermediate_Lower',  '7');
INSERT INTO Level VALUES ('8', 'Intermediate_Middle', '8');
INSERT INTO Level VALUES ('9', 'Intermediate_Upper',  '9');
INSERT INTO Level VALUES ('10','Advanced',            '10');
INSERT INTO Level VALUES ('11','Advanced_Lower',      '11');
INSERT INTO Level VALUES ('12','Advanced_Middle',     '12');
INSERT INTO Level VALUES ('13','Advanced_Upper',      '13');

CREATE TABLE ReleaseType (
  id INTEGER NOT NULL UNIQUE,
  labelToken TEXT NOT NULL UNIQUE,
  locationInOrder INTEGER NOT NULL UNIQUE
)  ;
INSERT INTO ReleaseType VALUES ('1', 'Alpha',      '1');
INSERT INTO ReleaseType VALUES ('2', 'Beta',       '2');
INSERT INTO ReleaseType VALUES ('3', 'Production', '3');

CREATE TABLE TextDisplayType (
  id INTEGER NOT NULL UNIQUE,
  typeName  TEXT NOT NULL UNIQUE
)  ;

INSERT INTO TextDisplayType VALUES ('1', 'textNativeLanguage');
INSERT INTO TextDisplayType VALUES ('2', 'textTargetLanguage');
INSERT INTO TextDisplayType VALUES ('3', 'textTargetLanguagePhonetic');

CREATE TABLE LessonVersion (
  lessonVersionSignature TEXT NOT NULL,
  contentProviderId TEXT NOT NULL,
  libraryId TEXT NOT NULL,
  publishedLessonVersionId TEXT,
  publishedLessonVersionVersion TEXT,
  assetsFileSize INTEGER,
  defaultTextDisplayTypeId INTEGER,
  isDualLanguage BOOL,
  levelId INTEGER NOT NULL,
  nativeLanguageAudioVolumeAdjustmentFactor REAL,
  paidContent BOOL,
  releaseType TEXT NOT NULL,
  targetLanguageAudioVolumeAdjustmentFactor REAL,
  xmlFileSize INTEGER,
  uploaded BOOL
)  ;

CREATE TABLE LessonVersionNativeLanguage (
  lessonVersionSignature TEXT NOT NULL,
  contentProviderId TEXT NOT NULL,
  languageId INTEGER NOT NULL,
  iso639_3Code TEXT NOT NULL,
  description TEXT,
  lessonName TEXT NOT NULL,
  lessonSortName TEXT NOT NULL,
  contentProviderName TEXT NOT NULL,
  libraryName TEXT NOT NULL,
  creditsXML TEXT
) ;

CREATE TABLE LessonVersionTargetLanguage (
  lessonVersionSignature TEXT NOT NULL,
  contentProviderId TEXT NOT NULL,
  languageId INTEGER NOT NULL,
  iso639_3Code TEXT NOT NULL
) ;

CREATE TABLE Chunk (
  lessonVersionSignature TEXT NOT NULL,
  contentProviderId TEXT NOT NULL,
  locationInOrder INTEGER NOT NULL,
  fileNameRoot TEXT NOT NULL,
  chunkType TEXT,
  textAudio TEXT,
  textDisplay TEXT,
  textNativeLanguage TEXT,
  textTargetLanguage TEXT,
  textTargetLanguagePhonetic TEXT,
  suppressed BOOL,
  uploaded BOOL
)  ;

CREATE TABLE ChunkFile (
  lessonVersionSignature TEXT NOT NULL,
  contentProviderId TEXT NOT NULL,
  chunkLocationInOrder INTEGER NOT NULL,
  duration INTEGER NOT NULL,
  fileNameBody TEXT NOT NULL
) ;


























