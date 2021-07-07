# Core repository of wildstacksexamples

This repository includes code that is oftenly used among wildstacksexamples projects. It includes:

 - classess for decoding outputs/inputs, payment ids,
 - general utility tools (e.g., get default wildstacks blockchain path),
 - unified representation of wildstacks addresses/accounts,
 - identification of outputs for subaddresses based on primary address,
 - estimation of possible spendings based on address and viewkey. 

# Example usage

More examples along with its full code are located in [example.cpp](https://github.com/wildstacks/xmregcore/blob/master/example.cpp).

### Identify outputs in a tx based on address and viewkey with subaddresses

```C++
// use WildStacks forum donation address and viewkwey.
// will search for outputs in a give tx to
// to the primary address and its subaddresses. 
auto primary_account = xmreg::make_primaryaccount(
        "45ttEikQEZWN1m7VxaVN9rjQkpSdmpGZ82GwUps66neQ1PqbQMno4wMY8F5jiDt2GoHzCtMwa7PDPJUJYb1GYrMP4CwAwNp",
        "c9347bc1e101eab46d3a6532c5b6066e925f499b47d285d5720e6a6f4cc4350c");

auto tx = get_tx("54cef43983ca9eeded46c6cc1091bf6f689d91faf78e306a5ac6169e981105d8");

// so now we can create an instance of a universal identifier
// which is going to identify outputs in a given tx using
// address and viewkey data. the search will include subaddresses.
auto identifier = make_identifier(*tx,
      make_unique<xmreg::Output>(primary_account.get()));

identifier.identify();

// get the results of the identification
auto outputs_found = identifier.get<xmreg::Output>()->get();

cout << "Found following outputs in tx " << tx << ":\n"
     << outputs_found << '\n';
```

Identified output for `0.081774999238` xmr is for a subaddress of index `0/10` 
which in this case is for the
["xiphon part time coding (3 months)"](https://ccs.getmonero.org/proposals/xiphon-part-time.html)
  proposal.

### Possible spending based on address and viewkey

```C++
// use offical WildStacks project donation address and viewkwey.
// will search for outputs and inputs in a give tx addressed 
// to the primary address only. this search will not account
// for any outputs sent to subaddresses.
auto account = xmreg::make_account(
        "44AFFq5kSiGBoZ4NMDwYtN18obc8AemS33DBLWs3H7otXft3XjrpDtQGv7SqSsaBYBb98uNbr2VBBEt7f2wfn3RVGQBEP3A",
        "f359631075708155cc3d92a32b75a7d02a5dcf27756707b47a2b31b21c389501");

auto tx = get_tx("aa739a3ce8d3171a422ed3a3f5016384cdb17a5d3eb5905021f1103574d47eaf");

// we can join individual identifiers as shown below, since to estimate
// spendings we need to identify possible inputs with their amount values,
// as well as outputs corresponding to the change returned to WildStacks
// donation address
auto identifier = make_identifier(*tx,
      make_unique<xmreg::Output>(account.get()),
      make_unique<xmreg::GuessInput>(account.get(), &mcore));

identifier.identify();

// get identified outputs and inputs in the tx
auto outputs_found = identifier.get<xmreg::Output>()->get();
auto inputs_found = identifier.get<xmreg::GuessInput>()->get();

// possible spending is just basic math
auto possible_total_spent = xmreg::calc_total_xmr(inputs_found)
                            - xmreg::calc_total_xmr(outputs_found)
                            - get_tx_fee(*tx);

cout << "Possible spending from WildStacks project donation is: " 
     << print_money(possible_total_spent) << " xmr\n";
```

Result is `118.778154000000` xmr which possibly were withdrawn from 
WildStacks donation address.

### Identify and decrypt integrated payment id 

```C++
// use WildStacks forum donation address and viewkwey
auto account = xmreg::make_account(
    "45ttEikQEZWN1m7VxaVN9rjQkpSdmpGZ82GwUps66neQ1PqbQMno4wMY8F5jiDt2GoHzCtMwa7PDPJUJYb1GYrMP4CwAwNp",
    "c9347bc1e101eab46d3a6532c5b6066e925f499b47d285d5720e6a6f4cc4350c");

auto tx = get_tx("401bf77c9a49dd28df5f9fb15846f9de05fce5f0e11da16d980c4c9ac9156354");

auto identifier = make_identifier(*tx,
  make_unique<xmreg::IntegratedPaymentID>(account.get()));

identifier.identify();

auto payment_id = identifier.get<xmreg::IntegratedPaymentID>()->get();

cout << "Found following itegrated payment id in tx " << payment_id << '\n';
```

The result is decrypted short payment id of `1fcbb836a748f4dc`. The tx is also
a possible withdrawn from WildStacks forum donation wallet for `350` xmr 
(see examples.cpp for the code). 

# Compilation

The project depends on wildstacks libraries and it has same dependecies as the wildstacks  
(except C++14 requirement). Thus wildstacks needs to be setup first.

### WildStacks download and compilation

Follow instructions in the following link:

https://github.com/wildstacks/wildstacks/blob/master/README.md

### Compilation of the xmregcore

C++14 is required to compile the project. This means that
GCC 7.1 or higher can be used. For example, Ubuntu 18.04 ships with
GCC 7.3 which is sufficient.

```bash
# go to home folder if still in ~/wildstacks
cd ~

git clone --recurse-submodules  https://github.com/wildstacks/xmregcore.git

cd xmregcore

mkdir build && cd build

cmake ..

# alternatively can use cmake -DWILDSTACKS_DIR=/path/to/wildstacks_folder ..
# if wildstacks is not in ~/wildstacks

make

# run tests
make test
```

# How can you help?

Constructive criticism and code are always welcomed. They can be made through github.
