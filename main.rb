require "google_drive"
require_relative 'table'

# session = GoogleDrive::Session.from_config("config.json")

# ws = session.spreadsheet_by_key("1-a1rlP_3fkneVTSDBto7ewW5snB8pRxSysw8HlQnz1M").worksheets[0]
# p ws[3, 1]  # cell(3, 1) prvo ide red pa kolona

# Worksheet.new("1-a1rlP_3fkneVTSDBto7ewW5snB8pRxSysw8HlQnz1M", 0).each do |entry|
#     p entry
# end

t = Table.new("1-a1rlP_3fkneVTSDBto7ewW5snB8pRxSysw8HlQnz1M", 0)

# t.row(2)
# p t["PrvaKolona"].to_s
# p t["PrvaKolona"][2]
# p t["Prva Kolona"][1] = 3
# p t["Prva Kolona"].to_s
# p t.prvaKolona.to_s
# p t.prvaKolona.sum
# p t.prvaKolona.avg

t.each {|row| p row}
# p t.indeks.rn11522

# p t.prvaKolona.map { |cell| cell+=1 }
# p t.prvaKolona.select { |num|  num.even? }
# p t.prvaKolona.reduce(1) { |sum, n| sum + n }

# t.print

#Headers: ["adsgsdag", "dsagasdg"]
# Row: ["1", "2"]
# Row: ["1", "2"]