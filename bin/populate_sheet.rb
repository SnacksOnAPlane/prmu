require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'pry'
require 'sqlite3'
require 'i18n'
require_relative '../cities'
I18n.available_locales = [:en]

SS_ID = "1pcBR6InPnOYhzC-EdEJv0c4FySZajSDZt5DeUDhGzhc"
SCOPE = "https://www.googleapis.com/auth/spreadsheets"
INITIAL_POPULATE = false
GCREDS = File.join(File.dirname(__FILE__), '../gcreds.json')

@service = Google::Apis::SheetsV4::SheetsService.new
@service.client_options.application_name = 'PRMU'
@service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(json_key_io: File.open(GCREDS), scope: SCOPE)

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

def append_cells_request(sheet_id, rows)
  rows = rows.map do |row|
    values = row.map do |c|
      { user_entered_value: { string_value: c } }
    end
    { values: values }
  end

  {
    append_cells: {
      sheet_id: sheet_id,
      rows: rows,
      fields: "*"
    }
  }
end

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

def posts_for_city(city_id, date)
   @db.execute("SELECT message, id, updated_time FROM posts JOIN city_posts ON city_posts.post_id = posts.id WHERE city_posts.city_id = ? AND updated_time > date(?)", [ city_id, date.to_s ]) { |row| yield row }
end

def populate_sheet_since(date)
  requests = []
  city_id_to_sheet_id_mapping = create_city_id_to_sheet_id_mapping

  city_id_to_sheet_id_mapping.keys.each do |city_id|
    sheet_id = city_id_to_sheet_id_mapping[city_id]
    rows = []
    posts_for_city(city_id, date) do |message, id, updated_time|
      group_id, post_id = id.split("_")
      link = "https://www.facebook.com/groups/prmariaupdates/permalink/#{post_id}/"
      if I18n.transliterate(message.downcase).match(/[^a-z](aee|luz|power|aaa|agua|oasis|senal|comunicacion|recepcion)[^a-z]/)
        rows.push([message, link, updated_time])
      end
    end
    rows.each_slice(500) do |slice|
      requests.push(append_cells_request(sheet_id, slice)) if slice
    end
  end

  len = requests.length

  requests.each_slice(50) do |slice|
    puts len
    len -= 50
    data = { requests: slice }
    @service.batch_update_spreadsheet(SS_ID, data, {})
  end
end

if __FILE__ == $0
  populate_sheet_since(Date.new(2017,1,1))
end
