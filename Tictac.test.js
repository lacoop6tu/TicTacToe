
const EVM_REVERT ='VM Exception while processing transaction: revert'



const TicTac = artifacts.require("./TicTac");


require('chai')
	.use(require('chai-as-promised'))
    .should()
    


contract('TicTac', ([deployer,gamer1, gamer2]) => {
	
	
	describe('some tests', () => {
	
	let result

	beforeEach(async ()=> {

        
       
        tictac = await TicTac.new() 
       
		
			})


		
		
		it('gamer1 creates game, gamer2 joins and gamer1 wins in row, and security checks ', async ()=>  {
		 
			
			result = await tictac.startGame({from: gamer1})

			result = await tictac.totalGames()

			console.log('totalGames', result.toString())
			
			result = await tictac.viewGame(1)

			console.log('Game1', result)

			result = await tictac.enterGame(2,{from: gamer2}).should.be.rejectedWith(EVM_REVERT) // id doesn't exist

			result = await tictac.enterGame(1,{from: gamer1}).should.be.rejectedWith(EVM_REVERT) // cannot enter twice

			result = await tictac.enterGame(1,{from: gamer2})

			result = await tictac.viewGame(1)

			console.log('Game1', result)

			
			await tictac.makeMove(1,0,0, {from:gamer2}).should.be.rejectedWith(EVM_REVERT) // not his turn, in this specific case with those addresses

			await tictac.makeMove(1,0,0, {from:gamer1})

			await tictac.makeMove(1,1,0, {from:gamer1}).should.be.rejectedWith(EVM_REVERT) // cannot play again

			await tictac.makeMove(1,0,0, {from:gamer2}).should.be.rejectedWith(EVM_REVERT) // cannot play an already filled cell
			
			await tictac.makeMove(1,1,1, {from:gamer2})
			
			await tictac.makeMove(1,1,0, {from:gamer1})

			await tictac.makeMove(1,1,2, {from:gamer2})

			// gamer1 wins in row 
			result = await tictac.makeMove(1,2,0, {from:gamer1})

			console.log(result.logs[1].args[1].toString(), 'enum WinnerState corresponds to PlayerOne') // returns 1 which is the enum playerOne


			result = await tictac.viewGame(1)

			console.log('GameState after ending, returns 2 which is Played', result[0].toString()) // returns 2 which is Played

			await tictac.makeMove(1,0,0, {from:gamer2}).should.be.rejectedWith(EVM_REVERT)  // cannot play anymore because game ended

		})

		it('gamer1 creates game, gamer2 joins and gamer2 wins in column', async ()=>  {
		 
			
			result = await tictac.startGame({from: gamer1})


			result = await tictac.enterGame(1,{from: gamer2})


			
			await tictac.makeMove(1,0,0, {from:gamer2}).should.be.rejectedWith(EVM_REVERT) // not his turn, in this specific case with those addresses

			await tictac.makeMove(1,1,0, {from:gamer1})
			
			await tictac.makeMove(1,0,0, {from:gamer2})
			
			await tictac.makeMove(1,1,1, {from:gamer1})

			await tictac.makeMove(1,0,1, {from:gamer2})

			await tictac.makeMove(1,2,1, {from:gamer1})

			//gamer2 wins in column
			result = await tictac.makeMove(1,0,2, {from:gamer2})
			

			console.log(result.logs[1].args[1].toString(), 'enum WinnerState corresponds to PlayerTwo') // returns 2 which is the enum playerTwo
			



		})

		it('gamer1 creates game, gamer2 joins and gamer2 wins in diagonal', async ()=>  {
		 
			
			result = await tictac.startGame({from: gamer1})


			result = await tictac.enterGame(1,{from: gamer2})


			
			await tictac.makeMove(1,0,0, {from:gamer2}).should.be.rejectedWith(EVM_REVERT) // not his turn, in this specific case with those addresses

			await tictac.makeMove(1,1,0, {from:gamer1})
			
			await tictac.makeMove(1,0,0, {from:gamer2})
			
			await tictac.makeMove(1,0,1, {from:gamer1})

			await tictac.makeMove(1,1,1, {from:gamer2})

			await tictac.makeMove(1,2,1, {from:gamer1})

			//gamer2 wins in column
			result = await tictac.makeMove(1,2,2, {from:gamer2})
			

			console.log(result.logs[1].args[1].toString(), 'enum WinnerState corresponds to PlayerTwo') // returns 2 which is the enum playerTwo
			



		})


		it('gamer1 creates game, gamer2 joins and draw game', async ()=>  {
		 
			
			result = await tictac.startGame({from: gamer1})


			result = await tictac.enterGame(1,{from: gamer2})

			await tictac.makeMove(1,2,0, {from:gamer1})
			
			await tictac.makeMove(1,0,0, {from:gamer2})
			
			await tictac.makeMove(1,0,1, {from:gamer1})

			await tictac.makeMove(1,0,2, {from:gamer2})

			await tictac.makeMove(1,2,2, {from:gamer1})

			await tictac.makeMove(1,2,1, {from:gamer2})

			await tictac.makeMove(1,1,2, {from:gamer1})

			await tictac.makeMove(1,1,0, {from:gamer2})

			// gamer2 makes last move
			result = await tictac.makeMove(1,1,1, {from:gamer1})

			

			console.log(result.logs[1].args[1].toString(), 'enum WinnerState corresponds to Draw') // returns 3 which is the enum Draw
			



		})

	
	

	})
	
})
