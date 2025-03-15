require 'digest'

class Block
  attr_reader :index, :timestamp, :transactions, :transactions_count, :previous_hash, :nonce, :hash, :creator, :merkle_root

  def initialize(index, transactions, previous_hash, creator)
    @index            = index
    @timestamp        = Time.now
    @transactions     = transactions
    @transactions_count = transactions.size
    @previous_hash    = previous_hash
    @creator          = creator
    @merkle_root      = compute_merkle_root(transactions)
    @nonce, @hash     = compute_hash_with_proof_of_work
  end

  def compute_merkle_root(transactions)
    return Digest::SHA256.hexdigest('') if transactions.empty?
    return Digest::SHA256.hexdigest(transactions.join) if transactions.size == 1

    new_level = []
    transactions.each_slice(2) do |left, right|
      right = left if right.nil?
      new_level << Digest::SHA256.hexdigest(left.to_s + right.to_s)
    end
    compute_merkle_root(new_level)
  end

  def compute_hash_with_proof_of_work(difficulty = "00")
    nonce = 0
    loop do 
      hash = calc_hash_with_nonce(nonce)
      return [nonce, hash] if hash.start_with?(difficulty)
      nonce += 1
    end
  end

  def calc_hash_with_nonce(nonce = 0)
    sha = Digest::SHA256.new
    sha.update(nonce.to_s +
               @index.to_s +
               @timestamp.to_s +
               @transactions.to_s +
               @transactions_count.to_s +
               @previous_hash +
               @merkle_root)
    sha.hexdigest
  end

  def self.first(*transactions)
    Block.new(0, transactions, "0", "Elam")
  end

  def self.next(previous, transactions, creator = "Unknown")
    Block.new(previous.index + 1, transactions, previous.hash, creator)
  end
end