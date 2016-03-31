require 'google/apis/script_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'fileutils'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'SWET IP Updater'
CLIENT_SECRETS_PATH = 'client_secret.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             "script-swet-ip-updater.yaml")
SCOPE = 'https://www.googleapis.com/auth/spreadsheets'

##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the user's default browser will be launched to approve the request.
#
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
def authorize
  FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

  client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(
      client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(
        base_url: OOB_URI)
    puts "Open the following URL in the browser and enter the " +
             "resulting code after authorization"
    puts url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI)
  end
  credentials
end

# @param [String] interface_name
# @return [Array] of parameters
def parameters(interface_name)
  hostname = `hostname`.chop
  ip = `ipconfig getifaddr #{interface_name}`.chop
  [hostname, ip]
end

# Initialize the API
service = Google::Apis::ScriptV1::ScriptService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize
#SCRIPT_ID = 'MKKVQ3YNMr98E4Rp3NbUgftFSUfbbRH05'
#SCRIPT_ID = 'MFsVtK_T-kplMFmE1PLjvzKIm4yBM2IlG'
SCRIPT_ID = 'Mj7Vld-AOO76fSUHLG_TFJqIm4yBM2IlG'



# Create an execution request object.
request = Google::Apis::ScriptV1::ExecutionRequest.new(
    function: 'updateIP',
    parameters: parameters('en0')
)

begin
  # Make the API request.
  resp = service.run_script(SCRIPT_ID, request)

  if resp.error
    # The API executed, but the script returned an error.

    # Extract the first (and only) set of error details. The values of this
    # object are the script's 'errorMessage' and 'errorType', and an array of
    # stack trace elements.
    error = resp.error.details[0]

    puts "Script error message: #{error['errorMessage']}"

    if error['scriptStackTraceElements']
      # There may not be a stacktrace if the script didn't start executing.
      puts "Script error stacktrace:"
      error['scriptStackTraceElements'].each do |trace|
        puts "\t#{trace['function']}: #{trace['lineNumber']}"
      end
    end
  else
    # The structure of the result will depend upon what the Apps Script function
    # returns. Here, the function returns an Apps Script Object with String keys
    # and values, and so the result is treated as a Ruby hash (folderSet).

    puts resp.response['result']

    # folder_set = resp.response['result']
    # if folder_set.length == 0
    #   puts "No folders returned!"
    # else
    #   puts "Folders under your root folder:"
    #   folder_set.each do |id, folder|
    #     puts "\t#{folder} (#{id})"
    #   end
    # end
  end
rescue Google::Apis::ClientError
  # The API encountered a problem before the script started executing.
  puts "Error calling API!"
end
