CREATE INDEX idx_countryId ON wca_dev.competitions (countryId);
CREATE INDEX idx_competitions_endDate ON wca_dev.competitions (end_date);
CREATE INDEX idx_countries_id ON wca_dev.countries (id);
CREATE INDEX idx_events_rank_id ON wca_dev.events (`rank`, id);
CREATE INDEX idx_persons_country_subid ON wca_dev.persons (countryId, subid);
CREATE INDEX idx_ranksaverage_personId_eventId_best ON wca_dev.ranksaverage (personId, eventId, best);
CREATE INDEX idx_rankssingle_personId_eventId_best ON wca_dev.ranksSingle (personId, eventId, best);
CREATE INDEX idx_rankssingle_person_event ON wca_dev.ranksSingle (personId, eventId);
CREATE INDEX idx_competitionId ON wca_dev.results (competitionId);
CREATE INDEX idx_countryId ON wca_dev.results (countryId);
CREATE INDEX idx_results_eventId ON wca_dev.results (eventId);
CREATE INDEX idx_results_roundTypeId ON wca_dev.results (roundTypeId);
CREATE INDEX idx_results_pos ON wca_dev.results (pos);
CREATE INDEX idx_roundTypeId ON wca_dev.roundTypes (id);