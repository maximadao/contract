from brownie import Maxima, accounts

def main():
    acct = accounts.load('maxima')
    Maxima.deploy("max-test-token", "MAXTEST001", 100000000, {'from': acct})