# r/millionairemakers/ example and pseudo-code
# a pseudo-lottery originally trying to solve r/millionairemakers problem of how to distibute funds
# in a decentralized manner.
# one difficulty was doing this without needing to have a random number generator. the solution
# chosen was to use pre-defined block numbers for seeds.
# written initially in vyper and then translated to solidity.

# intiating variables
is_open: False
beneficiary: null
pool: {sender: address, value: int}
draw_time: int # timedelta constant
safe_time: int # timedelta constant
stop_time: timedelta


# initialize contract with variable up top
def init:
    pass


# close contract to determine winner
def close_participations:
    # if self.open and timestamp > participation_limit:
        # self.open = False
    pass


@public
@payable
def participate():
    """
    pay to participate in the draw.

    """
    assert block.timestamp < self.deadline
    assert msg.value == participation_cost # TODO: remove deprecated participation_cost

    self.pool[] = {sender: msg.sender}

# participate in the fund
@payable
def participate:
    pool[].append(msg.sender)
    pass

# get seed from block number
def get_seed:
    pass

# get pool index number of lucky winner
def get_winner:
    pass

# draw winner from list of pool
def draw:
    # random pick from pool using seed from
    # winner = random ^
    # beneficiary = winner
    pass


# send eth to winner
def finalize:
    # send(self.winner)
    selfdestruct(self.beneficiary)
    pass
