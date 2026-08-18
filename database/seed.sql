-- Public, clearly-labelled demo data. It is not official travel, safety, weather, or emergency data.
insert into public.expense_categories(name, icon) values
  ('Transport','directions_car'), ('Accommodation','hotel'), ('Food','restaurant'),
  ('Tickets','confirmation_number'), ('Shopping','shopping_bag'), ('Emergency','emergency'), ('Other','more_horiz')
on conflict (name) do nothing;

insert into public.destinations(id, name, country, latitude, longitude) values
  ('10000000-0000-0000-0000-000000000001', 'Munnar', 'India', 10.0889, 77.0595)
on conflict (id) do nothing;

insert into public.places(id, external_place_id, name, category, description, latitude, longitude, rating, price_level, address, opening_hours, source) values
  ('20000000-0000-0000-0000-000000000001','demo-tea-walk','Tea Garden Walk','attraction','Demo attraction listing. Verify before travel.',10.0863,77.0600,4.6,1,'Munnar, Kerala','{"notice":"Verify opening hours"}','SMART TRIP demo seed'),
  ('20000000-0000-0000-0000-000000000002','demo-eravikulam','Eravikulam National Park','attraction','Demo attraction listing. Verify official conditions before travel.',10.1390,77.0620,4.7,2,'Rajamalai, Munnar','{"notice":"Verify opening hours"}','SMART TRIP demo seed'),
  ('20000000-0000-0000-0000-000000000003','demo-saravana','Saravana Bhavan Munnar','food','Demo vegetarian-friendly food listing.',10.0898,77.0590,4.3,1,'Main Bazaar, Munnar','{"notice":"Verify dietary options"}','SMART TRIP demo seed'),
  ('20000000-0000-0000-0000-000000000004','demo-cloudscape','Cloudscape Homestay','stay','Demo accommodation listing.',10.0940,77.0530,4.5,2,'Munnar, Kerala','{"notice":"Verify price and availability"}','SMART TRIP demo seed'),
  ('20000000-0000-0000-0000-000000000005','demo-health','Munnar Community Health Centre','essential','Demo essential-service point; never use as emergency guidance.',10.0905,77.0618,4.0,1,'Munnar, Kerala','{"notice":"Verify independently"}','SMART TRIP demo seed')
on conflict (id) do nothing;

insert into public.restaurants(place_id, dietary_options) values ('20000000-0000-0000-0000-000000000003', '["Vegetarian"]') on conflict (place_id) do nothing;
insert into public.accommodations(place_id, amenity_data) values ('20000000-0000-0000-0000-000000000004', '{"demo":true}') on conflict (place_id) do nothing;

insert into public.reviews(place_id, external_review_id, rating, text, author_name, published_at, source) values
  ('20000000-0000-0000-0000-000000000003','demo-review-1',4.0,'Demo review: pleasant vegetarian options.','Demo visitor',now(),'SMART TRIP demo seed'),
  ('20000000-0000-0000-0000-000000000004','demo-review-2',4.0,'Demo review: quiet location.','Demo visitor',now(),'SMART TRIP demo seed')
on conflict (place_id, external_review_id) do nothing;

insert into public.danger_zones(id, name, description, latitude, longitude, radius_meters, risk_level, source, active, is_demo) values
  ('30000000-0000-0000-0000-000000000001','Demo landslide caution area','Demonstration-only zone. Not an official warning.',10.1110,77.0970,600,'caution','SMART TRIP demo seed',true,true),
  ('30000000-0000-0000-0000-000000000002','Demo restricted-risk area','Demonstration-only zone. Not an official warning.',10.1185,77.1025,350,'high','SMART TRIP demo seed',true,true)
on conflict (id) do nothing;

insert into public.alerts(id, alert_type, title, message, severity, source, valid_from, valid_until, is_demo) values
  ('40000000-0000-0000-0000-000000000001','weather','DEMO: heavy-rain disruption','Demo alert for a re-planning walkthrough. Verify current weather with an approved provider.','caution','SMART TRIP demo seed',now(),now() + interval '12 hours',true)
on conflict (id) do nothing;

-- Private sample trips, expenses, photos and timeline records require a real auth.users ID.
-- Create a demo user through Supabase Auth, then insert private demo data as that user
-- (or through a controlled server-side seed) so RLS and foreign keys remain correct.

