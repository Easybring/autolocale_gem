require 'test/unit'
require 'autolocale'
require 'yaml'

class AutoLocaleTest < Test::Unit::TestCase

  def test_compare
    file1 = "en_complete.yml"
    file2 = "en_incomplete.yml"

    # write the two hashes as yaml files
    File.open(file1, "w") do |out|
      YAML.dump(complete_hash, out)
    end
    File.open(file2, "w") do |out|
      YAML.dump(incomplete_hash, out)
    end

    # run the program
    AutoLocale.compare(file1, file2)
    # this should find 2 problems (but the files should not be changed):
    # ┌────────────────────────────────────┬──────────────────────────────────────┐
    # │ Type of error                      │ Path                                 │
    # ├────────────────────────────────────┼──────────────────────────────────────┤
    # │ Wrong value type (String vs Array) │ hash.another_hash.should_be_a_string │
    # │ Missing translation                │ hash.another_hash.missing_string     │
    # └────────────────────────────────────┴──────────────────────────────────────┘

    # load files into hashes
    result1 = YAML.load_file(file1)
    result2 = YAML.load_file(file2)

    # delete the files
    File.delete(file1, file2)

    # check results
    assert_equal complete_hash, result1, "File 1 was not expected to be changed."
    assert_equal incomplete_hash, result2, "File 2 was not expected to be changed."
  end

  def test_automerge
    file1 = "en_complete.yml"
    file2 = "en_incomplete.yml"

    # write the two hashes as yaml files
    File.open(file1, "w") do |out|
      YAML.dump(complete_hash, out)
    end
    File.open(file2, "w") do |out|
      YAML.dump(incomplete_hash, out)
    end

    # run the program
    AutoLocale.automerge(file1, file2)
    # this should add the "missing_string" key and it's value to file2.
    # the type mismatch should still be present:
    # ┌────────────────────────────────────┬──────────────────────────────────────┐
    # │ Type of error                      │ Path                                 │
    # ├────────────────────────────────────┼──────────────────────────────────────┤
    # │ Wrong value type (String vs Array) │ hash.another_hash.should_be_a_string │
    # └────────────────────────────────────┴──────────────────────────────────────┘

    # load files into hashes
    result1 = YAML.load_file(file1)
    result2 = YAML.load_file(file2)

    # delete the files
    File.delete(file1, file2)

    # check results
    assert_equal complete_hash, result1, "File 1 was not expected to be changed."
    assert_not_equal incomplete_hash, result2, "File 2 was expected to be changed."
  end


  private

  def complete_hash
    {
      "en" => {
        "testString" => "foo",
        "hash" => {
          "string" => "baz",
          "another_hash" => {
            "array" => [
              "foo",
              "baz",
              "bar"
            ],
            "should_be_a_string" => "And it indeed is",
            "missing_string" => "You shouldn't find me in en_incomplete.yml"
          }
        }
      }
    }
  end

  def incomplete_hash
    {
      "en" => {
        "testString" => "foo-boo",
        "hash" => {
          "string" => "stuff",
          "another_hash" => {
            "array" => [
              "blah",
              "blargh",
              "asdf"
            ],
            "should_be_a_string" => [
              "but it is..",
              "..an array"
            ]
          }
        }
      }
    }
  end

end