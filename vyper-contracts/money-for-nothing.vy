# r/millionairemakers/ example and pseudo-code
# a pseudo-lottery originally trying to solve r/millionairemakers problem of how to distibute funds
# in a decentralized manner.
# one difficulty was doing this without needing to have a random number generator. the solution
# chosen was to use pre-defined block numbers for seeds.
# written initially in vyper and then translated to solidity.
#
# WARNING: this contract has not been audited and the authors are not responsible for any lost funds


# declaring state variables
is_open: public(bool) # DEPCRECATED
beneficiary: public(address)
players: {sender: address, value: wei_value, cumm_pool: wei_value}[int128]
next_player_index: int128 # default value 0, doesn't require init.
pool_size: wei_value
stop_block: uint256
draw_block: uint256
ending_block: uint256
checked_index: int128

#     <------------ game_duration -----------><-- offset1 --><---- offset2 ------>
#     |---------------------------------------|-------------|--------------------|
# Deploy block                           stop_block    draw_block          ending_block

@public
def __init__(game_duration: uint256, offset1: uint256, offset2: uint256):    
    self.stop_block = block.number + game_duration 
    self.draw_block = self.stop_block + offset1
    self.ending_block = self.draw_block + offset2
    self.is_open = True

# pay to participate in the game
@public
@payable
def participate():    
    assert block.number < self.stop_block

    self.pool_size = self.pool_size + msg.value
    self.players[self.next_player_index] = {sender: msg.sender, value: msg.value, cumm_pool: self.pool_size}
    self.next_player_index = self.next_player_index + 1
    

@public
def close_participations():
    """
    DEPRECATED as is_open is not used
    close contract and prevent additional players to participate
    """
    if self.is_open and block.number >= self.stop_block:
        self.is_open = False    

# get seed from block number
@private
def get_seed() -> (uint256):    
    # assert block.number >= self.draw_block and block.
    # return convert(block.blockhash(self.draw_block), 'int128')
    return convert(blockhash(self.draw_block), 'uint256')

@private
def get_winner(seed: uint256) -> (address):
    """
    returns address of winner
    """            
    magic_number: uint256
    # magic_number: wei_value

    # magic_number = seed % convert(self.pool_size, 'int128')
    magic_number = seed % as_unitless_number(self.pool_size)
    ind: int128 = self.next_player_index

    for i in range(self.checked_index, self.checked_index + 30):
        if i >= self.next_player_index:
            self.checked_index = self.next_player_index
            return ZERO_ADDRESS

        if as_unitless_number(self.players[i].cumm_pool) >= magic_number:
            return self.players[i].sender

    self.checked_index = self.checked_index + 30
    
# draw winner from list of pool
@public
def draw():
    # random pick from pool using seed from    
    assert block.number >= self.draw_block
    seed: uint256
    seed = self.get_seed()
    self.beneficiary = self.get_winner(seed)

@public
def finalize():
    """
    Send eth to winner and destroy contract
    """
    assert block.number >= self.ending_block
    assert self.beneficiary != ZERO_ADDRESS
    selfdestruct(self.beneficiary) # destructs contract and sends balance to beneficiary