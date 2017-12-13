/*
 * Shengjie Hu
 */

#define N	5
#define L	10
byte I;
byte nr_leaders = 0;
byte highestNum = 0;
mtype = {one, two, winner};
chan q[N] = [L] of {mtype, byte};

proctype nnode (chan inp, out; byte mynumber) {
	bit Active = 1, know_winner = 0;
	byte nr, maximum = mynumber, neighborR;

	xr inp;
	xs out;

	printf("MSC: %d\n", mynumber);
	out ! one(mynumber);
end:
	do
		:: inp ? one(nr) ->
			if
				:: Active ->
					if
						:: nr != maximum ->
							out ! two(nr);
							neighborR = nr;
						:: else ->
							if 
								::nr == mynumber ->
									nr_leaders = nr_leaders + 1;
								::else
							fi
							know_winner = 1;
							out ! winner(nr);
					fi
				:: else ->
					out ! one(nr)
			fi
		:: inp ? two(nr) ->
			if
				:: Active ->
					if
						:: neighborR > nr && neighborR > maximum ->
							maximum = neighborR;
							out ! one(neighborR)
						:: else ->
							Active = 0;
					fi
				:: else ->
					out ! two(nr);
			fi
		:: inp ? winner, nr ->
			printf("highestNum = %d, nr = %d\n", highestNum, nr);
			assert(highestNum == nr);
			printf("I know that %d is the biggest one! %d\n", nr, mynumber);
			if
				:: nr != mynumber ->
					printf("MSC: LOST %d\n", mynumber);
				:: else ->
					nr_leaders = nr_leaders + 1;
					printf("MSC: LEADER %d\n", mynumber);
			fi;
			if
				:: know_winner
				:: else -> out ! winner(nr);
			fi;
			break
	od;
	assert(nr_leaders <= 1);
	printf("nr_leades = %d\n", nr_leaders);
	printf("There is only one leaders.\n");
}

init {
	byte proc;
	byte Ini[6];
	atomic {
		I = 1;
		do
			:: I <= N ->
				if
					:: Ini[0] == 0 && N >= 1 -> Ini[0] = I;
					:: Ini[1] == 0 && N >= 2 -> Ini[1] = I;
					:: Ini[2] == 0 && N >= 3 -> Ini[2] = I;
					:: Ini[3] == 0 && N >= 4 -> Ini[3] = I;
					:: Ini[4] == 0 && N >= 5 -> Ini[4] = I;
					:: Ini[5] == 0 && N >= 6 -> Ini[5] = I;
				fi;
				I++
			:: I > N ->
				break
		od;
		int i = 0;
		for (i : 0 .. 4) {
			if
				::Ini[i] > highestNum ->
					highestNum = Ini[i];
				::else
			fi;
		}
		proc = 1;
		do
			:: proc <= N ->
				run nnode(q[proc - 1], q[proc % N], Ini[proc - 1]);
				proc++;
			:: proc > N ->
				break
		od
	}
}
