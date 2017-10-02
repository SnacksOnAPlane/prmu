require 'sqlite3'

CITIES = <<-end
Adjuntas
Aguada
Aguadilla
Aguas Buenas
Aibonito
Añasco
Arecibo
Arroyo
Barceloneta
Barranquitas
Bayamon
Cabo Rojo
Caguas
Caguas
Camuy
Canóvanas
Carolina
Cataño
Cayey
Ceiba
Ciales
Cidra
Coamo
Comerío
Corozal
Culebra
Dorado
Fajardo
Florida
Guayama
Guayanilla
Guaynabo
Gurabo
Guánica
Hatillo
Hormigueros
Humacao
Isabela
Isla Verde
Jayuya
Juana Díaz
Juncos
Lajas
Lares
Las Marías
Las Piedras
Luquillo
Loiza
Manati
Maricao
Maunabo
Mayagüez
Moca
Morovis
Naguabo
Naranjito
Orocovis
Patillas
Peñuelas
Ponce
Quebradillas
Rincón
Rio Grande
Sabana Grande
Salinas
San Germán
San Juan
San Lorenzo
San Sebastián
Santa Isabel
Toa Alta
Toa Baja
Trujillo Alto
Utuado
Vega Alta
Vega Baja
Villalba
Yabucoa
Yauco
end

@db = SQLite3::Database.new "prmu.db"

@db.execute <<-SQL
  create table cities (
    id INTEGER PRIMARY KEY,
    name TEXT
  );
SQL

CITIES.split("\n").each do |city|
  @db.execute("INSERT INTO cities (name) VALUES (?)", [ city ])
end
