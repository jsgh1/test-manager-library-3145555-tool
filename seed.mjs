// Contract-only demonstration seeder. All state changes use HTTP API endpoints.
const api=(process.env.API_URL||'http://localhost:8000/api/v1').replace(/\/$/,'');
const username=process.env.ADMIN_USERNAME;
const password=process.env.ADMIN_PASSWORD;
if(!username||!password)throw Error('Configure ADMIN_USERNAME and ADMIN_PASSWORD as environment variables.');
let token='';
async function call(path,method='GET',body){
 const response=await fetch(api+path,{method,headers:{'Content-Type':'application/json',...(token?{Authorization:'Bearer '+token}:{})},...(body?{body:JSON.stringify(body)}:{})});
 const data=await response.json().catch(()=>({}));
 if(!response.ok)throw Error(method+' '+path+' '+response.status+' '+(data.code||data.message||''));
 return data;
}
function isbn(i){return '978'+String(1000000000+i).padStart(10,'0');}
const stamp=Date.now().toString(36);
console.log('Starting API-only demonstration seed',stamp);
const auth=await call('/auth/login','POST',{username,password});token=auth.access_token;
const categories=await call('/categories');
if(categories.length!==5)throw Error('Expected five fixed categories.');
const books=[];
for(let i=0;i<40;i++){
 const category=categories[i%categories.length];
 books.push(await call('/books','POST',{title:'Demo title '+(i+1)+' — '+stamp,author:'Demo author '+(1+i%9),isbn:isbn((Date.now()%100000000)+i),category_id:category.id,total_copies:3+i%4}));
}
console.log('Created',books.length,'books');
const members=[];
for(let i=0;i<10;i++)members.push(await call('/members','POST',{full_name:'Demo Member '+(i+1)+' '+stamp,document_number:'D'+stamp+'-'+(i+1)}));
console.log('Created',members.length,'members');
const loans=[];
for(let i=0;i<15;i++){
 const member=members[i%10];
 // Five different members get two loans with distinct books; each still has <=3 open items.
 loans.push(await call('/loans','POST',{member_id:member.id,items:[{book_id:books[i].id}]}));
}
console.log('Created',loans.length,'loans');
const now=new Date(),from=now.toISOString().slice(0,10),to=from;
const report=await call('/reports/most-borrowed?from='+from+'&to='+to);
console.log('Report rows:',report.rows.length);
const overdue=await call('/loans/overdue');
console.log('Overdue lines:',overdue.items?.length||0);
console.warn('DOCUMENTED SPECIFICATION CONFLICT: T-21 additionally requires three overdue lines. API requests cannot override the server loan timestamp and each new loan is due in 14 days. This program does not fake or circumvent that requirement.');
console.log('API-only seed completed: 40 books, 10 members, 15 loans.');
