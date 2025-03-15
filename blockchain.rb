require 'digest'                # Para SHA256
require 'pp'                    # Para pretty printing
# require 'pry'                 # Para debugging en el momento
require_relative 'block'        # Clase Block
require_relative 'transaction'  # Métodos para transacciones

# Clase que representa un bloque en la blockchain.
class Block
  attr_reader :index, :timestamp, :transactions, :transactions_count, :previous_hash, :nonce, :hash, :creator

  # Inicializa un nuevo bloque.
  # @param index [Integer] el índice del bloque.
  # @param transactions [Array] transacciones incluidas en el bloque.
  # @param previous_hash [String] hash del bloque anterior.
  # @param creator [String] creador del bloque.
  def initialize(index, transactions, previous_hash, creator)
    @index              = index
    @timestamp          = Time.now
    @transactions       = transactions
    @transactions_count = transactions.size
    @previous_hash      = previous_hash
    @creator            = creator
    @nonce, @hash       = compute_hash_with_proof_of_work
  end

  # Busca un hash válido siguiendo las reglas de Proof of Work (PoW).
  # Por defecto, el hash debe iniciar con "00". Para aumentar la dificultad,
  # puedes modificar este parámetro (por ejemplo, usar "0000").
  #
  # @param difficulty [String] la cadena que debe iniciar el hash.
  # @return [Array] con el nonce y el hash válido.
  def compute_hash_with_proof_of_work(difficulty = "00")
    nonce = 0
    loop do 
      hash = calc_hash_with_nonce(nonce)
      return [nonce, hash] if hash.start_with?(difficulty)
      nonce += 1
    end
  end

  # Calcula el hash del bloque usando el nonce proporcionado.
  # @param nonce [Integer] valor usado para la minería.
  # @return [String] hash resultante.
  def calc_hash_with_nonce(nonce = 0)
    sha = Digest::SHA256.new
    sha.update(nonce.to_s +
               @index.to_s +
               @timestamp.to_s +
               @transactions.to_s +
               @transactions_count.to_s +
               @previous_hash)
    sha.hexdigest
  end

  # Crea el bloque génesis (el primer bloque de la cadena).
  # @param transactions [Array] transacciones iniciales.
  # @return [Block] el bloque génesis.
  def self.first(*transactions)
    Block.new(0, transactions, "0", "Elam")
  end

  # Crea el siguiente bloque en la cadena.
  # @param previous [Block] el bloque anterior.
  # @param transactions [Array] transacciones para el nuevo bloque.
  # @param creator [String] (opcional) creador del bloque, por defecto "Unknown".
  # @return [Block] el nuevo bloque.
  def self.next(previous, transactions, creator = "Unknown")
    Block.new(previous.index + 1, transactions, previous.hash, creator)
  end
end

# Array para almacenar la cadena de bloques.
LEDGER = []

# Crea y añade el bloque génesis a la cadena.
def create_first_block(num_blocks)
  genesis = Block.first(
    { from: "Dutchgrown", to: "Vincent", what: "Tulip Bloemendaal Sunset", qty: 10 },
    { from: "Keukenhof", to: "Anne", what: "Tulip Semper Augustus", qty: 7 }
  )
  LEDGER << genesis
  pp genesis
  puts "============================"
  add_block(num_blocks)
end

# Añade nuevos bloques a la cadena.
# @param num_blocks [Integer] número de bloques a añadir.
def add_block(num_blocks)
  i = 1
  while i < num_blocks
    # Se asume que get_transactions_data retorna un array con las transacciones para el nuevo bloque.
    new_block = Block.next(LEDGER[i - 1], get_transactions_data)
    LEDGER << new_block
    puts "============================"
    pp new_block
    puts "============================"
    i += 1
  end
end

# Función para obtener datos de transacciones (dummy data para este ejemplo).
def get_transactions_data
  [
    { from: "Alice", to: "Bob", what: "Bitcoin", qty: 1 },
    { from: "Charlie", to: "Dave", what: "Ethereum", qty: 2 }
  ]
end

# Función para iniciar la ejecución del blockchain.
def launcher
  puts "==========================="
  puts ""
  puts "Welcome to Simple Blockchain In Ruby!"
  puts ""
  sleep 1.5
  puts "This program was created by Anthony Amar for educational purposes"
  puts ""
  sleep 1.5
  puts "Wait for the genesis (the first block of the blockchain)"
  puts ""
  10.times do
    print "."
    sleep 0.5
  end
  puts "\n\n==========================="
  create_first_block(10)  # Añadir 10 bloques en total
end

launcher