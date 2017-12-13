/*
 * Shengjie Hu
 */

#define N 5
#define L 10

mtype = {electe, leader};
chan ch[N] = [L] of {mtype, byte};
proctype nnode(byte id, next_id) {
	byte leader_id;
	byte eId, lId;
	ch[next_id] ! electe(id);
	do
		:: ch[id] ? electe, eId ->
			printf("%d received: %d electe\n", id, eId);
			if
				:: eId > id ->
					printf("%d is sending {electe %d} to %d\n", id, eId, next_id);
					ch[next_id] ! electe(eId)
				:: eId == id ->
					printf("find leader, %d send to the ring\n", id);
					ch[next_id] ! leader(eId)
				:: else ->
			fi;
		:: ch[id] ? leader, lId ->
			leader_id = lId;
			printf("%d received: %d is leader\n", id, lId);
			if
				:: id != lId ->
					printf("MSC: LOST\n");
					ch[next_id] ! leader(lId)
				:: id == lId ->
					printf("MSC: LEADER%d\n", lId);
			fi
	od

}

init {
	atomic {
		byte i = 0;
		do
			:: i < N ->
				printf("Initilizing %d\n", i);
				byte id = i;
				byte next_id = (i - 1 + N) % N;
				run nnode(id, next_id);
				i++
			:: i >= N ->
				break
		od
	}

}
