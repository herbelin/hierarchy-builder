Require Import String ssreflect ssrfun ssrbool hb classical.
Require Import ZArith QArith.
From elpi Require Import elpi.

Declare Scope hb_scope.
Delimit Scope hb_scope with G.

Local Open Scope classical_set_scope.
Local Open Scope hb_scope.

Module Stage10.

Elpi hb.structure TYPE.

Elpi hb.declare_mixin AddAG_of_TYPE A.
  Record axioms := Axioms {
    zero : A;
    add : A -> A -> A;
    opp : A -> A;
    addrA : associative add;
    addrC : commutative add;
    add0r : left_id zero add;
    addNr : left_inverse zero opp add;
  }.
Elpi hb.end.
Elpi hb.structure AddAG AddAG_of_TYPE.axioms.

Notation "0" := zero : hb_scope.
Infix "+" := (@add _) : hb_scope.
Notation "- x" := (@opp _ x) : hb_scope.
Notation "x - y" := (x + - y) : hb_scope.

(* Theory *)

Section AddAGTheory.
Variable A : AddAG.type.
Implicit Type (x : A).

Lemma addr0 : right_id (@zero A) add.
Proof. by move=> x; rewrite addrC add0r. Qed.

Lemma addrN : right_inverse (@zero A) opp add.
Proof. by move=> x; rewrite addrC addNr. Qed.

Lemma subrr x : x - x = 0.
Proof. by rewrite addrN. Qed.

Lemma addrK : right_loop (@opp A) (@add A).
Proof. by move=> x y; rewrite -addrA subrr addr0. Qed.

Lemma addKr : left_loop (@opp A) (@add A).
Proof. by move=> x y; rewrite addrA addNr add0r. Qed.

Lemma addrNK : rev_right_loop (@opp A) (@add A).
Proof. by move=> y x; rewrite -addrA addNr addr0. Qed.

Lemma addNKr : rev_left_loop (@opp A) (@add A).
Proof. by move=> x y; rewrite addrA subrr add0r. Qed.

Lemma addrAC : right_commutative (@add A).
Proof. by move=> x y z; rewrite -!addrA [y + z]addrC. Qed.

Lemma addrCA : left_commutative (@add A).
Proof. by move=> x y z; rewrite !addrA [x + y]addrC. Qed.

Lemma addrACA : interchange (@add A) add.
Proof. by move=> x y z t; rewrite !addrA [x + y + z]addrAC. Qed.

Lemma opprK : involutive (@opp A).
Proof. by move=> x; apply: (can_inj (addrK (- x))); rewrite addNr addrN. Qed.

Lemma opprD x y : - (x + y) = - x - y.
Proof.
apply: (can_inj (addKr (x + y))).
by rewrite subrr addrACA !subrr addr0.
Qed.

Lemma opprB x y : - (x - y) = y - x.
Proof. by rewrite opprD opprK addrC. Qed.

End AddAGTheory.

Elpi hb.declare_mixin Ring_of_AddAG A AddAG.axioms.
  Record axioms := Axioms {
    one : A;
    mul : A -> A -> A;
    mulrA : associative mul;
    mulr1 : left_id one mul;
    mul1r : right_id one mul;
    mulrDl : left_distributive mul add;
    mulrDr : right_distributive mul add;
  }.
Elpi hb.end.
Elpi hb.declare_factory Ring_of_TYPE A.
  Record axioms := Axioms {
    zero : A;
    one : A;
    add : A -> A -> A;
    opp : A -> A;
    mul : A -> A -> A;
    addrA : associative add;
    addrC : commutative add;
    add0r : left_id zero add;
    addNr : left_inverse zero opp add;
    mulrA : associative mul;
    mul1r : left_id one mul;
    mulr1 : right_id one mul;
    mulrDl : left_distributive mul add;
    mulrDr : right_distributive mul add;
  }.

  Variable a : axioms.
  Definition to_AddAG_of_TYPE := AddAG_of_TYPE.Axioms_ A
    _ _ _ (addrA a) (addrC a) (add0r a) (addNr a).
  Elpi hb.canonical A to_AddAG_of_TYPE.
  Definition to_Ring_of_AddAG :=
    Ring_of_AddAG.Axioms _ _ (mulrA a) (mul1r a)
      (mulr1 a)
      (mulrDl a : left_distributive _ (@AddAG.Exports.add _)) (mulrDr a).
  Elpi hb.canonical A to_Ring_of_AddAG.
Elpi hb.end.

Elpi hb.structure Ring Ring_of_TYPE.axioms.

Notation "1" := one : hb_scope.
Infix "*" := (@mul _) : hb_scope.

Elpi hb.declare_mixin Topological T.
Record axioms := Axioms {
  open : (T -> Prop) -> Prop;
  open_setT : open setT;
  open_bigcup : forall {I} (D : set I) (F : I -> set T),
    (forall i, D i -> open (F i)) -> open (\bigcup_(i in D) F i);
  open_setI : forall X Y : set T, open X -> open Y -> open (setI X Y);
  }.
Elpi hb.end.
Elpi hb.structure TopologicalSpace Topological.axioms.

Hint Extern 0 (open setT) => now apply: open_setT : core.

Elpi hb.declare_factory TopologicalBase T.
  Record axioms := Axioms {
    open_base : set (set T);
    open_base_covers : setT `<=` \bigcup_(X in open_base) X;
    open_base_cup : forall X Y : set T, open_base X -> open_base Y ->
      forall z, (X `&` Y) z -> exists2 Z, open_base Z & Z z /\ Z `<=` X `&` Y
  }.
  Variable a : axioms.

  Definition open_of :=
    [set A | exists2 D, D `<=` open_base a & A = \bigcup_(X in D) X].

  Lemma open_of_setT : open_of setT.  Proof.
  exists (open_base a); rewrite // predeqE => x; split=> // _.
  by apply: open_base_covers.
  Qed.

  Lemma open_of_bigcup {I} (D : set I) (F : I -> set T) :
    (forall i, D i -> open_of (F i)) -> open_of (\bigcup_(i in D) F i).
  Proof. Admitted.

  Lemma open_of_cap X Y : open_of X -> open_of Y -> open_of (X `&` Y).
  Proof. Admitted.

  Definition to_Topological :=
    Topological.Axioms _ open_of_setT (@open_of_bigcup) open_of_cap.
  Elpi hb.canonical T to_Topological.

Elpi hb.end.

Section ProductTopology.
  Variables (T1 T2 : TopologicalSpace.type).

  Definition prod_open_base :=
    [set A | exists (A1 : set T1) (A2 : set T2),
      open A1 /\ open A2 /\ A = setM A1 A2].

  Lemma prod_open_base_covers : setT `<=` \bigcup_(X in prod_open_base) X.
  Proof.
  move=> X _; exists setT => //; exists setT, setT; do ?split.
  - exact: open_setT.
  - exact: open_setT.
  - by rewrite predeqE.
  Qed.

  Lemma prod_open_base_setU X Y :
    prod_open_base X -> prod_open_base Y ->
      forall z, (X `&` Y) z ->
        exists2 Z, prod_open_base Z & Z z /\ Z `<=` X `&` Y.
  Proof.
  move=> [A1 [A2 [A1open [A2open ->]]]] [B1 [B2 [B1open [B2open ->]]]].
  move=> [z1 z2] [[/=Az1 Az2] [/= Bz1 Bz2]].
  exists ((A1 `&` B1) `*` (A2 `&` B2)).
    by eexists _, _; do ?[split; last first]; apply: open_setI.
  by split => // [[x1 x2] [[/=Ax1 Bx1] [/=Ax2 Bx2]]].
  Qed.

  Definition prod_topology :=
    TopologicalBase.Axioms _ prod_open_base_covers prod_open_base_setU.
  Elpi hb.canonical (TopologicalSpace.sort T1 * TopologicalSpace.sort T2)%type prod_topology.

End ProductTopology.

Definition continuous {T T' : TopologicalSpace.type} (f : T -> T') :=
  forall B : set T', open B -> open (f@^-1` B).

Definition continuous2 {T T' T'': TopologicalSpace.type}
  (f : T -> T' -> T'') := continuous (fun xy => f xy.1 xy.2).

Elpi hb.declare_mixin JoinTAddAG
  T AddAG_of_TYPE.axioms Topological.axioms.
  Record axioms := Axioms {
    add_continuous : continuous2 (add : T -> T -> T);
    opp_continuous : continuous (opp : T -> T)
  }.
Elpi hb.end.

Elpi hb.structure TAddAG
  Topological.axioms AddAG_of_TYPE.axioms
  JoinTAddAG.axioms.

(* Instance *)

Definition Z_ring_axioms :=
  Ring_of_TYPE.Axioms 0%Z 1%Z Z.add Z.opp Z.mul
    Z.add_assoc Z.add_comm Z.add_0_l Z.add_opp_diag_l
    Z.mul_assoc Z.mul_1_l Z.mul_1_r
    Z.mul_add_distr_r Z.mul_add_distr_l.
Elpi hb.canonical Z Z_ring_axioms.

Example test1 (m n : Z) : (m + n) - n + 0 = m.
Proof. by rewrite addrK addr0. Qed.

Require Import Qcanon.
Search _ Qc "plus" "opp".

Lemma Qcplus_opp_l q : - q + q = 0.
Proof. by rewrite Qcplus_comm Qcplus_opp_r. Qed.

Definition Qc_ring_axioms :=
  Ring_of_TYPE.Axioms 0%Qc 1%Qc Qcplus Qcopp Qcmult
    Qcplus_assoc Qcplus_comm Qcplus_0_l Qcplus_opp_l
    Qcmult_assoc Qcmult_1_l Qcmult_1_r
    Qcmult_plus_distr_l Qcmult_plus_distr_r.
Elpi hb.canonical Qc Qc_ring_axioms.

Obligation Tactic := idtac.
Definition Qcopen_base : set (set Qc) := 
  [set A | exists a b : Qc, forall z, A z <-> a < z /\ z < b].
Program Definition QcTopological := TopologicalBase.Axioms_ Qc Qcopen_base _ _.
Next Obligation.
move=> x _; exists [set y | x - 1 < y < x + 1].
  by exists (x - 1), (x + 1).
split; rewrite Qclt_minus_iff.
  by rewrite -[_ + _]/(x - (x - 1))%G opprB addrCA subrr.
by rewrite -[_ + _]/(x + 1 - x)%G addrAC subrr.
Qed.
Next Obligation.
move=> X Y [aX [bX Xeq]] [aY [bY Yeq]] z [/Xeq [aXz zbX] /Yeq [aYz zbY]].
Admitted.
Elpi hb.canonical Qc QcTopological.

Program Definition QcJoinTAddAG := JoinTAddAG.Axioms_ Qc _ _.
Next Obligation. Admitted.
Next Obligation. Admitted.
Elpi hb.canonical Qc QcJoinTAddAG.

End Stage10.