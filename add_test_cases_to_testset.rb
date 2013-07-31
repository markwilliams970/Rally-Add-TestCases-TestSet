# Copyright 2002-2012 Rally Software Development Corp. All Rights Reserved.

require 'rally_api'
require 'csv'

$my_base_url       = "https://rally1.rallydev.com/slm"
$my_username       = "user@company.com"
$my_password       = "password"
$my_workspace      = "My Workspace"
$my_project        = "My Project"
$wsapi_version     = "1.43"
$filename          = 'add_test_cases_to_testset.csv'

# Load (and maybe override with) my personal/private variables from a file...
my_vars= File.dirname(__FILE__) + "/my_vars.rb"
if FileTest.exist?( my_vars ) then require my_vars end

# Load (and maybe override with) my personal/private variables from a file...
my_vars= File.dirname(__FILE__) + "/my_vars.rb"
if FileTest.exist?( my_vars ) then require my_vars end

$test_set_cache = {}

# We need to cache each TestCase/TestSet pair and do _one_ add operation per
# TestSet for performance reasons
def cache_testcase(header, row)
  test_case_formatted_id                   = row[header[0]].strip
  target_test_set_formatted_id             = row[header[2]].strip

  # Lookup Source Test Case
  # Lookup test case to move
  test_case_query = RallyAPI::RallyQuery.new()
  test_case_query.type = :testcase
  test_case_query.fetch = "FormattedID,ObjectID,TestFolder,Project,Name"
  test_case_query.query_string = "(FormattedID = \"" + test_case_formatted_id + "\")"

  test_case_query_result = @rally.find(test_case_query)

  if test_case_query_result.total_result_count == 0
    puts "Test Case #{test_case_formatted_id} not found...skipping"
    return
  end

  source_test_case = test_case_query_result.first

  if !$test_set_cache.has_key?(target_test_set_formatted_id)
    puts "Adding Test Set #{target_test_set_formatted_id} to Test Set cache."
    puts "Caching Test Case #{test_case_formatted_id} for addition to Test Set #{target_test_set_formatted_id}"
    $test_set_cache[target_test_set_formatted_id] = [source_test_case]
  else
    puts "Caching Test Case #{test_case_formatted_id} for addition to Test Set #{target_test_set_formatted_id}"
    $test_set_cache[target_test_set_formatted_id].push(source_test_case)
  end
end

def add_test_cases_to_sets(cached_sets)
  # Loop through TestSets in cache hash
  cached_sets.each_pair do | target_test_set_formatted_id, test_case_array |
    # Lookup Target Test Set
    target_test_set_query = RallyAPI::RallyQuery.new()
    target_test_set_query.type = :testset
    target_test_set_query.fetch = "FormattedID,ObjectID,Name,TestCases,FormattedID,ObjectID,TestFolder,Project,Name"
    target_test_set_query.query_string = "(FormattedID = \"" + target_test_set_formatted_id + "\")"

    target_test_set_query_result = @rally.find(target_test_set_query)

    if target_test_set_query_result.total_result_count == 0
      puts "Target Test Set: #{target_test_set_formatted_id} not found."
      puts "Skipping Test Set: #{target_test_set_formatted_id}."
      next
    end

    target_test_set = target_test_set_query_result.first
    existing_test_cases = target_test_set["TestCases"]

    if !existing_test_cases.nil? then
      existing_test_case_array = []
      existing_test_cases.each do | this_test_case |
        existing_test_case_array.push(this_test_case)
      end
      updated_test_cases = existing_test_case_array.concat(test_case_array)
    else
      updated_test_cases = test_case_array
    end    

    test_set_update_fields = {}
    test_set_update_fields["TestCases"] = updated_test_cases

    # Try the update
    begin
      target_test_set.update(test_set_update_fields)
      puts "Test Set #{target_test_set_formatted_id} successfully added #{test_case_array.length} Test Cases."
    rescue => ex    
      puts "Test Set #{target_test_set_formatted_id} not updated due to error"
      puts ex.message
      puts ex.backtrace
    end
  end
end

begin
  #==================== Making a connection to Rally ====================
  config                  = {:base_url => $my_base_url}
  config[:username]       = $my_username
  config[:password]       = $my_password
  config[:workspace]      = $my_workspace
  config[:project]        = $my_project
  config[:version]        = $wsapi_version

  @rally = RallyAPI::RallyRestJson.new(config)

  input  = CSV.read($filename)

  header = input.first #ignores first line

  rows   = []
  (1...input.size).each { |i| rows << CSV::Row.new(header, input[i]) }

  rows.each do |row|
    cache_testcase(header, row)
  end

  # Process Cached TestSet/TestCases Hash
  add_test_cases_to_sets($test_set_cache)
  puts "Finished!"

end