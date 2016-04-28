var balanceSpan = document.querySelector('#balance')
var amountInput = document.querySelector('#amount')
var withdrawButton = document.querySelector('#withdraw')
var depositButton = document.querySelector('#deposit')
var eventStack = document.querySelector('#events')

var _ = eventuality

var anAccountNumber = '12345'

var BankAccount = _.defineAggregate({
  name: 'BankAccount',
  state: {
    balance: 0
  },
  methods: {
    withdraw: function(amount) {
      var balance = this.state.balance - amount
      this.state.balance = balance
      return _.Event({
        name: 'WithDrawalEvent',
        aggregateId: this.id,
        payload: {
          amount: amount
        },
        state: {
          balance: balance
        }
      })
    },
    deposit: function(amount) {
      var balance = this.state.balance + amount
      this.state.balance = balance
      return _.Event({
        name: 'DepositEvent',
        aggregateId: this.id,
        payload: {
          amount: amount
        },
        state: {
          balance: balance
        }
      })
    }
  }
})

var Events = _.EventStore()

var BankAccounts = _.Repository('BankAccount', BankAccount, Events)
BankAccounts.add({ id: anAccountNumber, balance: 200 })

var WithDrawCommand = function(accountNumber, amount) {
  return {
    name: 'WithDraw',
    message: {
      accountNumber: accountNumber,
      amount: amount
    }
  }
}
var DepositCommand = function(accountNumber, amount) {
  return {
    name: 'Deposit',
    message: {
      accountNumber: accountNumber,
      amount: amount
    }
  }
}

var WithDrawCommandHandler = function(command) {
  return BankAccounts.load(command.accountNumber).then(function(bankAccount) {
    return bankAccount.withdraw(command.amount)
  })
}
var DepositCommandHandler = function(command) {
  return BankAccounts.load(command.accountNumber).then(function(bankAccount) {
    return bankAccount.deposit(command.amount)
  })
}

var logEvent = function(event) {
  var div = document.createElement('div')
  div.classList.add('event')
  var p = document.createElement('p')
  p.textContent = event.name
  var span = document.createElement('span')
  span.textContent = `amount: ${event.payload.amount}`
  div.appendChild(p)
  div.appendChild(span)
  eventStack.appendChild(div)
}

var EventBus = _.EventBus()
EventBus.registerListener('WithDrawalEvent', function(event) {
  balanceSpan.textContent = event.state.balance
  logEvent(event)
})
EventBus.registerListener('DepositEvent', function(event) {
  balanceSpan.textContent = event.state.balance
  logEvent(event)
})
EventBus.registerListener('BankAccountCreatedEvent', function(event) {
  logEvent(event)
})

var bankingSystem = _.Flow({
  commandHandlers: {
    WithDraw: WithDrawCommandHandler,
    Deposit: DepositCommandHandler
  },
  eventStore: Events,
  eventBus: EventBus
})

withdrawButton.onclick = function(e) {
  e.preventDefault()
  var amount = new Number(amountInput.value)
  bankingSystem.dispatch(WithDrawCommand(anAccountNumber, amount))
}

depositButton.onclick = function(e) {
  e.preventDefault()
  var amount = new Number(amountInput.value)
  bankingSystem.dispatch(DepositCommand(anAccountNumber, amount))
}
