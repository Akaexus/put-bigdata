REGISTER /usr/lib/pig/piggybank.jar;
-- trip = LOAD 'input/datasource4/name.basics.tsv' USING PigStorage(',');

-- nconst  primaryName     birthYear       deathYear       primaryProfession       knownForTitles
-- nm0000001       Fred Astaire    1899    1987    soundtrack,actor,miscellaneous  tt0072308,tt0043044,tt0050419,tt0053137
-- nm0000002       Lauren Bacall   1924    2014    actress,soundtrack      tt0038355,tt0117057,tt0037382,tt0071877
-- nm0000003       Brigitte Bardot 1934    \N      actress,soundtrack,producer     tt0057345,tt0054452,tt0049189,tt0059956
-- nm0000004       John Belushi    1949    1982    actor,writer,soundtrack tt0078723,tt0077975,tt0072562,tt0080455
-- nm0000005       Ingmar Bergman  1918    2007    writer,director,actor   tt0050986,tt0050976,tt0083922,tt0069467
-- nm0000006       Ingrid Bergman  1915    1982    actress,soundtrack,producer     tt0036855,tt0038109,tt0038787,tt0071877
-- nm0000007       Humphrey Bogart 1899    1957    actor,soundtrack,producer       tt0043265,tt0037382,tt0034583,tt0033870
-- nm0000008       Marlon Brando   1924    2004    actor,soundtrack,director       tt0068646,tt0047296,tt0078788,tt0070849
-- nm0000009       Richard Burton  1925    1984    actor,producer,soundtrack       tt0087803,tt0059749,tt0057877,tt0061184

movies_count = LOAD '$input_dir3/part-*' USING org.apache.pig.piggybank.storage.CSVExcelStorage(
  '\t',
  'NO_MULTILINE',
  'NOCHANGE'
) as (
  nconst:chararray,
  acted:int,
  directed:int
);

people = LOAD '$input_dir4/name.basics.tsv' USING org.apache.pig.piggybank.storage.CSVExcelStorage(
  '\t',
  'NO_MULTILINE',
  'NOCHANGE',
  'SKIP_INPUT_HEADER'
) as (
  nconst:chararray,
  primaryName:chararray,
  birthYear:int,
  deathYear:chararray,
  primaryProfession:chararray,
  knownForTitles:chararray
);
-- https://stackoverflow.com/questions/62338341/how-to-convert-string-to-tuple-in-pig
people_with_professions = FOREACH people GENERATE nconst, primaryName, TOKENIZE(primaryProfession, ',') as professions;

joined_people = JOIN people_with_professions BY nconst, movies_count BY nconst;

directors_test = FOREACH joined_people {
  test = FILTER professions BY $0 == 'director';
  GENERATE *, test;
}
directors = FILTER directors_test BY NOT IsEmpty(test);



actors_test = FOREACH joined_people {
  test = FILTER professions BY ($0 == 'actor' OR $0 == 'actress');
  GENERATE *, test;
}
actors = FILTER actors_test BY NOT IsEmpty(test);

top_actors = ORDER actors by acted DESC;
top3_actors = LIMIT top_actors 3;
top3_actors_projected = FOREACH top3_actors GENERATE primaryName as primaryName, BagToString(test) as role, acted as movies;

top_directors = ORDER directors by directed DESC;
top3_directors = LIMIT top_directors 3;
top3_directors_projected = FOREACH top3_directors GENERATE primaryName as primaryName, BagToString(test) as role, directed as movies;

result = UNION top3_actors_projected, top3_directors_projected;

STORE result
    INTO '$output_dir6'
    USING JsonStorage();
