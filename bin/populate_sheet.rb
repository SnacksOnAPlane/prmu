require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'pry'
require 'sqlite3'
require_relative '../cities'

SS_ID = "1pcBR6InPnOYhzC-EdEJv0c4FySZajSDZt5DeUDhGzhc"
SCOPE = "https://www.googleapis.com/auth/spreadsheets"
INITIAL_POPULATE = false

@service = Google::Apis::SheetsV4::SheetsService.new
@service.client_options.application_name = 'PRMU'
@service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(json_key_io: File.open('/home/smiley/code/prmu/gcreds.json'), scope: SCOPE)

@sheet = @service.get_spreadsheet(SS_ID)

def add_sheet_request(city_name)
  {
    add_sheet: {
      properties: {
        title: city_name,
        grid_properties: {
          row_count: 10,
          column_count: 5
        }
      }
    }
  }
end

def update_sheet_properties
  {
    update_sheet_properties: {
      properties: { sheet_id: 0, title: "My New Title" },
      fields: "title"
    }
  }
end

def append_cells_request(sheet_id, row)
  values = row.map do |c|
    { user_entered_value: { string_value: c } }
  end

  {
    append_cells: {
      sheet_id: sheet_id,
      rows: [{ values: values }],
      fields: "*"
    }
  }
end

requests = []

if INITIAL_POPULATE
  CITIES.split("\n").each do |city|
    requests.push(add_sheet_request(city))
  end
end

@db = SQLite3::Database.new "prmu.db"

def find_sheet_num(city)
  our_sheet = @sheet.sheets.find { |s| s.properties.title == city }
  our_sheet.properties.sheet_id
end

def create_city_id_to_sheet_id_mapping
  mapping = {}
  @db.execute("SELECT id, name FROM cities") do |id, name|
    mapping[id] = find_sheet_num(name)
  end
  mapping
end

def posts_for_city(city_id)
  @db.execute("SELECT message, id, updated_time FROM posts JOIN city_posts ON city_posts.post_id = posts.id WHERE city_posts.city_id = ?", [ city_id ]) { |row| yield row }
end

city_id_to_sheet_id_mapping = create_city_id_to_sheet_id_mapping

city_id_to_sheet_id_mapping.keys.each do |city_id|
  sheet_id = city_id_to_sheet_id_mapping[city_id]
  posts_for_city(city_id) do |message, id, updated_time|
    group_id, post_id = id.split("_")
    link = "https://www.facebook.com/groups/prmariaupdates/permalink/#{post_id}/"
    requests.push(append_cells_request(sheet_id, [message, link, updated_time]))
  end
end

puts requests

data = {
  requests: requests
}

@service.batch_update_spreadsheet(SS_ID, data, {})
