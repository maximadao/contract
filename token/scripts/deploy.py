from brownie import Maxima, accounts

def main():
    acct = accounts.load('maxima')
    Maxima.deploy("max-test-token", "MAXTEST003", 100000000000000, {'from': acct})