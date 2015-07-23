#include <stdio.h>
#include <algorithm>

#define if if (
#define then )
#define do )
#define for for (
#define while while (
#define begin {
#define end }

char ch;
inline void read(int &x)
begin
  x=0;ch=getchar();
  while ch<=32 do ch=getchar();
  while ch>32 do x=x*10+ch-48,ch=getchar();
end;

inline void G(int x){while x-- do getchar();}

#define MAXN 50005
#define MAXM 250005

int n,q;

struct Info begin
  int mi,size;
  long long sum;
end;

typedef int Tag;

const Tag NULL_TAG=0;
const Info NULL_INFO=(Info){2147483647,0,0};

inline Info operator + (const Info &a,const Info &b)
begin
  return (Info){std::min(a.mi,b.mi),a.size+b.size,a.sum+b.sum};
end;

inline Info operator * (const Info &a,const Tag &b)
begin
  return a.size ? (Info){a.mi+b,a.size,a.sum+1LL*a.size*b} : a;
end;

#define is_NULL_tag(x) ((x)==0)

#define is_NULL_info(x) (x.size==0)

struct splay_node begin
  splay_node *s[2],*fa;
  Info x,sum;
  Tag tag,tag_sum;
  
  inline void add_tag(Tag t)
  begin
    x=x*t;sum=sum*t;
    tag=tag+t;tag_sum=tag_sum+t;
  end;
  
  inline void down()
  begin
    if is_NULL_tag(tag) then return;
    if s[0] then s[0]->add_tag(tag);
    if s[1] then s[1]->add_tag(tag);
    tag=NULL_TAG;
  end;
  
  inline void update()
  begin
    sum=x;
    if s[0] then sum=sum+s[0]->sum;
    if s[1] then sum=sum+s[1]->sum;
  end;
end;

splay_node _splay[MAXN+MAXM];

inline int get_parent(splay_node *x,splay_node *&fa)
begin
  return (fa=x->fa) ? fa->s[1]==x : -1;
end;

inline void rotate(splay_node *x)
begin
  splay_node *fa,*gfa;
  int t1,t2;
  t1=get_parent(x,fa);
  t2=get_parent(fa,gfa);
  if (fa->s[t1]=x->s[t1^1]) then fa->s[t1]->fa=fa;
  fa->fa=x;x->fa=gfa;x->s[t1^1]=fa;
  if t2!=-1 then gfa->s[t2]=x;
  fa->update();
end;

inline void pushdown(splay_node *x)
begin
  static splay_node *stack[MAXN+MAXM];
  int cnt=0;
  while x do begin
    stack[cnt++]=x;
    x=x->fa;
  end;
  while cnt-- do stack[cnt]->down();
end;

inline splay_node * splay(splay_node *x)
begin
  pushdown(x);
  while 1 do begin
    splay_node *fa,*gfa;
    int t1,t2;
    t1=get_parent(x,fa);
    if t1==-1 then break;
    t2=get_parent(fa,gfa);
    if t2==-1 then begin
      rotate(x);break;
    end else if t1==t2 then begin
      rotate(fa);rotate(x);
    end else begin
      rotate(x);rotate(x);
    end;
  end;
  x->update();
  return x;
end;

inline splay_node * join(splay_node *a,splay_node *b)
begin
  if !a then return b;
  if !b then return a;
  while a->s[1] do a->down(),a=a->s[1];
  splay(a)->s[1]=b;b->fa=a;
  a->update();
  return a;
end;

struct lcc_node;

struct cycle begin
  int A,B;
  lcc_node *ex;
end;

struct lcc_node begin
  lcc_node *s[2],*fa;
  lcc_node *first,*last;
  bool rev;
  bool isedge;
  
  bool mpath;
  bool hasmpath;
  bool mpathtag;
  bool hasmpathtag;
  
  bool hascyctag;
  bool hascyc;
  cycle *cyc;
  cycle *cyctag;
  
  int totlen;
  int len;
  int size;
  
  Info x,sum,sub,ex,all;
  Tag chain_tag,sub_tag,ex_tag_sum;
  
  inline void add_rev_tag()
  begin
    std::swap(s[0],s[1]);
    std::swap(first,last);
    rev^=1;
  end;
  
  inline void add_cyc_tag(cycle *c)
  begin
    if isedge then cyc=c;
    cyctag=c;
    hascyctag=1;
    hascyc=c;
  end;
  
  inline void add_mpath_tag(bool t)
  begin
    mpathtag=t;
    hasmpathtag=1;
    mpath=t&isedge;
    hasmpath=t&(isedge|(size>1));
  end;
  
  inline void add_chain_tag(Tag t)
  begin
    if is_NULL_tag(t) then return;
    x=x*t;sum=sum*t;
    chain_tag=chain_tag+t;
    all=sum+sub;
  end;
  
  inline void add_sub_tag(Tag t);
  
  inline void down()
  begin
    if rev then begin
      if s[0] then s[0]->add_rev_tag();
      if s[1] then s[1]->add_rev_tag();
      rev=0;
    end;
    if hascyctag then begin
      if s[0] then s[0]->add_cyc_tag(cyctag);
      if s[1] then s[1]->add_cyc_tag(cyctag);
      hascyctag=0;
    end;
    if hasmpathtag then begin
      if s[0] then s[0]->add_mpath_tag(mpathtag);
      if s[1] then s[1]->add_mpath_tag(mpathtag);
      hasmpathtag=0;
    end;
    if !is_NULL_tag(chain_tag) then begin
      if s[0] then s[0]->add_chain_tag(chain_tag);
      if s[1] then s[1]->add_chain_tag(chain_tag);
      chain_tag=NULL_TAG;
    end;
    if !is_NULL_tag(sub_tag) then begin
      if s[0] then s[0]->add_sub_tag(sub_tag);
      if s[1] then s[1]->add_sub_tag(sub_tag);
      sub_tag=NULL_TAG;
    end;
  end;
  
  inline void update();
  
end;

lcc_node lcc[MAXN+MAXM];
lcc_node *_node_tot;

splay_node *splay_root[MAXN+MAXM];

inline void lcc_node::add_sub_tag(Tag t)
begin
  if is_NULL_tag(t) then return;
  sub=sub*t;ex=ex*t;
  sub_tag=sub_tag+t;
  ex_tag_sum=ex_tag_sum+t;
  all=sum+sub;
  // add tag to splay_root
  int id=this-lcc;
  if splay_root[id] then begin
    splay_root[id]->add_tag(t);
  end;
end;

inline void lcc_node::update()
begin
  totlen=len;
  hascyc=cyc;
  size=1;
  hasmpath=mpath;
  if s[0] then totlen+=s[0]->totlen,hascyc|=s[0]->hascyc,size+=s[0]->size,hasmpath|=s[0]->hasmpath;
  if s[1] then totlen+=s[1]->totlen,hascyc|=s[1]->hascyc,size+=s[1]->size,hasmpath|=s[1]->hasmpath;
  first=s[0]?s[0]->first:this;
  last=s[1]?s[1]->last:this;
  bool s0=s[0],s1=s[1];
  if isedge then begin
    if is_NULL_info(ex) then begin
      if s0 && s1 then begin
        sum=s[0]->sum+s[1]->sum;
        sub=s[0]->sub+s[1]->sub;
      end else if s0 then begin
        sum=s[0]->sum;
        sub=s[0]->sub;
      end else if s[1] then begin
        sum=s[1]->sum;
        sub=s[1]->sub;
      end else begin
        sub=sum=NULL_INFO;
      end;
    end else begin
      if s0 && s1 then begin
        sum=s[0]->sum+s[1]->sum;
        sub=s[0]->sub+s[1]->sub+ex;
      end else if s0 then begin
        sum=s[0]->sum;
        sub=s[0]->sub+ex;
      end else if s[1] then begin
        sum=s[1]->sum;
        sub=s[1]->sub+ex;
      end else begin
        sum=NULL_INFO;
        sub=ex;
      end;
    end;
  end else begin
    splay_node *root=splay_root[this-lcc];
    if root then begin
      if s0 && s1 then begin
        sum=s[0]->sum+s[1]->sum+x;
        sub=s[0]->sub+s[1]->sub+root->sum;
      end else if s0 then begin
        sum=s[0]->sum+x;
        sub=s[0]->sub+root->sum;
      end else if s[1] then begin
        sum=s[1]->sum+x;
        sub=s[1]->sub+root->sum;
      end else begin
        sub=root->sum;
        sum=x;
      end;
    end else begin
      if s0 && s1 then begin
        sum=s[0]->sum+s[1]->sum+x;
        sub=s[0]->sub+s[1]->sub;
      end else if s0 then begin
        sum=s[0]->sum+x;
        sub=s[0]->sub;
      end else if s[1] then begin
        sum=s[1]->sum+x;
        sub=s[1]->sub;
      end else begin
        sum=x;
        sub=NULL_INFO;
      end;
    end;
  end;
  all=sum+sub;
end;

inline lcc_node * new_edge_node(int u,int v,int len)
begin
  lcc_node *ret=++_node_tot;
  ret->s[0]=ret->s[1]=ret->fa=NULL;
  ret->first=ret->last=ret;
  ret->rev=0;
  ret->isedge=1;
  ret->hascyctag=ret->hascyc=0;
  ret->cyc=ret->cyctag=NULL;
  ret->totlen=ret->len=len;
  ret->size=1;
  ret->x=ret->sum=ret->sub=ret->ex=ret->all=NULL_INFO;
  ret->chain_tag=ret->sub_tag=ret->ex_tag_sum=NULL_TAG;
  return ret;
end;

inline int get_parent(lcc_node *x,lcc_node *&fa)
begin
  return (fa=x->fa) ? fa->s[0]==x?0:fa->s[1]==x?1:-1 : -1;
end;

inline void rotate(lcc_node *x)
begin
  int t1,t2;
  lcc_node *fa,*gfa;
  t1=get_parent(x,fa);
  t2=get_parent(fa,gfa);
  if (fa->s[t1]=x->s[t1^1]) then fa->s[t1]->fa=fa;
  fa->fa=x;x->fa=gfa;x->s[t1^1]=fa;
  if t2!=-1 then gfa->s[t2]=x;
  fa->update();
end;

inline void pushdown(lcc_node *x)
begin
  static lcc_node *stack[MAXN+MAXM];
  int cnt=0;
  while 1 do begin
    stack[cnt++]=x;
    lcc_node *fa=x->fa;
    if !fa || (fa->s[0]!=x && fa->s[1]!=x) then break;
    x=fa;
  end;
  while cnt-- do stack[cnt]->down();
end;

inline lcc_node * splay(lcc_node *x)
begin
  pushdown(x);
  while 1 do begin
    int t1,t2;
    lcc_node *fa,*gfa;
    t1=get_parent(x,fa);
    if t1==-1 then break;
    t2=get_parent(fa,gfa);
    if t2==-1 then begin
      rotate(x);break;
    end else if t1==t2 then begin
      rotate(fa);rotate(x);
    end else begin
      rotate(x);rotate(x);
    end;
  end;
  x->update();
  return x;
end;

inline int getrank(lcc_node *x)
begin
  splay(x);
  return 1+(x->s[0]?x->s[0]->size:0);
end;

bool _attached[MAXN+MAXM];

inline void detach_rch(lcc_node *x)
begin
  if !x->s[1] then return;
  int X=x-lcc;
  int id=x->s[1]->first-lcc;
  _attached[id]=1;
  splay_node *p=_splay+id;
  p->s[0]=splay_root[X];
  if splay_root[X] then splay_root[X]->fa=p;
  p->s[1]=p->fa=NULL;
  p->x=x->s[1]->all;
  p->tag=p->tag_sum=NULL_TAG;
  p->update();
  splay_root[X]=p;
  x->s[1]=NULL;
end;

inline void attach_rch(lcc_node *x,lcc_node *y,int id)
begin
  int X=x-lcc;
  _attached[id]=0;
  splay_node *p=_splay+id;
  splay(p);
  if p->s[0] then p->s[0]->fa=NULL;
  if p->s[1] then p->s[1]->fa=NULL;
  splay_root[X]=join(p->s[0],p->s[1]);
  y->add_chain_tag(p->tag_sum);
  y->add_sub_tag(p->tag_sum);
  x->s[1]=y;
end;

inline void attach_rch(lcc_node *x,lcc_node *y,int id,int id2)
begin
  if _attached[id] then begin
    attach_rch(x,y,id);
  end else begin
    attach_rch(x,y,id2);
  end;
end;

inline void attach_rch(lcc_node *x,lcc_node *y)
begin
  if !y then return;
  attach_rch(x,y,y->first-lcc);
end;

inline lcc_node * access(lcc_node *x)
begin
  lcc_node *ret=NULL;
  int last_ex_last_id;
  while x do begin
    lcc_node *t=splay(x)->s[0];
    if !t then begin
      
      detach_rch(x);
      if ret then begin
        attach_rch(x,ret,ret->first-lcc,last_ex_last_id);
      end;
      
      ret=x;x->update();
      x=x->fa;
      continue;
    end;
    while t->s[1] do t->down(),t=t->s[1];
    if !splay(t)->cyc then begin
      splay(x);
      
      detach_rch(x);
      if ret then begin
        attach_rch(x,ret,ret->first-lcc,last_ex_last_id);
      end;
      
      ret=x;x->update();
      x=x->fa;
      continue;
    end;
    cycle *c=t->cyc;
    lcc_node *A=lcc+c->A,*B=lcc+c->B,*ex=splay(c->ex);
    bool need_tag_down=false;
    lcc_node *B_ex;
    if splay(B)->fa==A then begin
      
      detach_rch(B);
      
      B->s[1]=ex;ex->fa=B;B->update();
      need_tag_down=true;
      B_ex=B->s[0]->first;
    end else if splay(A)->fa==B then begin
      std::swap(c->A,c->B);std::swap(A,B);ex->add_rev_tag();
      
      detach_rch(B);
      
      B->s[1]=ex;ex->fa=B;B->update();
      need_tag_down=true;
      B_ex=B->s[0]->last;
    end else begin
      bool f=0;
      if getrank(A)>getrank(B) then begin
        std::swap(c->A,c->B);std::swap(A,B);ex->add_rev_tag();
        f=1;
      end;
      splay(A)->s[1]->fa=NULL;A->s[1]=NULL;A->update();
      splay(B);detach_rch(B);
      B->s[1]=ex;ex->fa=B;B->update();
      B_ex=f ? B->s[0]->last : B->s[0]->first;
    end;
    // add tag to ex
    Tag tag_ex=splay(B_ex)->ex_tag_sum;
    B_ex->ex=NULL_INFO;
    B_ex->update();
    ex=splay(B)->s[1];
    ex->add_chain_tag(tag_ex);
    ex->add_sub_tag(tag_ex);
    B->update();
    
    splay(x);c->B=x-lcc;
    if x->s[1]->totlen<x->s[0]->totlen then x->add_rev_tag();
    x->add_mpath_tag(x->s[1]->totlen==x->s[0]->totlen);
    x->down();
    c->ex=x->s[1];x->s[1]->fa=NULL;
    x->s[1]=NULL;
    x->update();
    lcc_node *tmp=splay(x->first);
    tmp->ex=c->ex->all;
    tmp->ex_tag_sum=NULL_TAG;
    tmp->update();
    splay(x);
    if ret then begin
      attach_rch(x,ret,ret->first-lcc,last_ex_last_id);
    end;
    x->update();
    last_ex_last_id=c->ex->last-lcc;
    if splay(A)->s[1] then begin
      ret=x;x=x->fa;
    end else begin
      if need_tag_down then begin
        attach_rch(A,x,c->ex->last-lcc,x->first-lcc);
      end;
      A->s[1]=x;x->fa=A;A->update();
      ret=A;x=A->fa;
    end;
  end;
  return ret;
end;

inline void setroot(int x)
begin
  access(lcc+x)->add_rev_tag();
end;

inline bool link(int u,int v,int len)
begin
  if u==v then return 0;
  setroot(u);
  lcc_node *t=access(lcc+v);
  while t->s[0] do t->down(),t=t->s[0];
  if splay(t)!=lcc+u then begin
    lcc_node *p=new_edge_node(u,v,len);
    p->fa=splay(lcc+u);
    lcc[u].s[0]=p;
    lcc[u].fa=lcc+v;
    lcc[u].update();
    splay(lcc+v)->s[1]=lcc+u;
    lcc[v].update();
    return 1;
  end;
  if t->hascyc then return 0;
  lcc_node *ex=new_edge_node(u,v,len);
  cycle *c=new cycle((cycle){u,v,ex});
  ex->add_cyc_tag(c);
  t->add_cyc_tag(c);
  access(lcc+v);
  return 1;
end;

inline bool cut(int u,int v,int len)
begin
  if u==v then return 0;
  setroot(u);
  lcc_node *t=access(lcc+v);
  while t->s[0] do t->down(),t=t->s[0];
  if splay(t)!=lcc+u then begin
    return 0;
  end;
  if !t->hascyc then begin
    if t->size!=3 then return 0;
    if t->totlen!=len then return 0;
    t=t->s[1];
    if t->s[0] then t->down(),t=t->s[0];
    splay(t);
    t->s[0]->fa=NULL;t->s[1]->fa=NULL;
    return 1;
  end;
  t=splay(lcc+v)->s[0];
  while t->s[1] do t->down(),t=t->s[1];
  cycle *c=splay(t)->cyc;
  if !c then return 0;
  t=splay(lcc+u)->s[1];
  while t->s[0] do t->down(),t=t->s[0];
  if splay(t)->cyc!=c then return 0;
  lcc_node *ex=c->ex;
  if ex->size==1 && ex->len==len then begin
    t->add_cyc_tag(NULL);
    t->add_mpath_tag(0);
    delete c;
    return 1;
  end;
  if t->size!=3 || t->len!=len then return 0;
  // lcc[u].mpath == 0 !
  ex->add_cyc_tag(NULL);
  ex->add_mpath_tag(0);
  ex->add_rev_tag();
  ex->add_sub_tag(t->ex_tag_sum);
  ex->add_chain_tag(t->ex_tag_sum);
  lcc[u].fa=lcc[v].fa=NULL;
  while ex->s[0] do ex->down(),ex=ex->s[0];
  splay(ex)->s[0]=lcc+u;lcc[u].fa=ex;ex->update();
  while ex->s[1] do ex->down(),ex=ex->s[1];
  splay(ex)->s[1]=lcc+v;lcc[v].fa=ex;ex->update();
  delete c;
  return 1;
end;

inline Info query_path(int u,int v)
begin
  setroot(u);
  lcc_node *t=access(lcc+v);
  while t->s[0] do t->down(),t=t->s[0];
  if splay(t)!=lcc+u then begin
    return (Info){-1,-1,-1};
  end;
  if t->hasmpath then begin
    return (Info){-2,-2,-2};
  end;
  return t->sum;
end;

inline Info query_subcactus(int u,int v)
begin
  setroot(u);
  lcc_node *t=access(lcc+v);
  while t->s[0] do t->down(),t=t->s[0];
  if splay(t)!=lcc+u then begin
    return (Info){-1,-1,-1};
  end;
  Info ret=splay(lcc+v)->x;
  if splay_root[v] then begin
    ret=ret+splay_root[v]->sum;
  end;
  return ret;
end;

inline bool modify_path(int u,int v,Tag tag)
begin
  setroot(u);
  lcc_node *t=access(lcc+v);
  while t->s[0] do t->down(),t=t->s[0];
  if splay(t)!=lcc+u then return 0;
  if t->hasmpath then return 0;
  t->add_chain_tag(tag);
  return 1;
end;

inline bool modify_subcactus(int u,int v,Tag tag)
begin
  setroot(u);
  lcc_node *t=access(lcc+v);
  while t->s[0] do t->down(),t=t->s[0];
  if splay(t)!=lcc+u then return 0;
  splay(lcc+v);
  lcc[v].x=lcc[v].x*tag;
  if splay_root[v] then begin
    splay_root[v]->add_tag(tag);
  end;
  lcc[v].update();
  return 1;
end;

int main()
begin
  read(n);read(q);
  int i;
  static int w[MAXN];
  for i=1;i<=n;i++ do begin
    read(w[i]);
    lcc[i].first=lcc[i].last=lcc+i;
    lcc[i].size=1;
    lcc[i].x=lcc[i].sum=lcc[i].all=(Info){w[i],1,w[i]};
    lcc[i].sub=lcc[i].ex=NULL_INFO;
    lcc[i].chain_tag=lcc[i].sub_tag=lcc[i].ex_tag_sum=NULL_TAG;
  end;
  _node_tot=lcc+n;
  for i=1;i<=q;i++ do begin
    char ch=getchar();
    while ch<=32 do ch=getchar();
    if ch=='l' then begin
      G(3);
      int u,v,len;
      read(u);read(v);read(len);
      puts(link(u,v,len) ? "ok" : "failed");
    end else if ch=='c' then begin
      G(2);
      int u,v,len;
      read(u);read(v);read(len);
      puts(cut(u,v,len) ? "ok" : "failed");
    end else if ch=='q' then begin
      G(4);
      ch=getchar();
      int u,v;
      read(u);read(v);
      Info ret;
      ret=ch=='1' ? query_path(u,v) : query_subcactus(u,v);
      printf("%d %lld\n",ret.mi,ret.sum);
    end else if ch=='a' then begin
      G(2);
      ch=getchar();
      int u,v,val;
      read(u);read(v);read(val);
      puts((ch=='1'?modify_path(u,v,val):modify_subcactus(u,v,val)) ? "ok" : "failed");
    end else begin
      puts("error");
    end;
  end;
end